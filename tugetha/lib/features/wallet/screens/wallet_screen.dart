import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/transaction_item.dart';
import 'topup_screen.dart';
import 'withdraw_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return userStream.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error loading wallet')),
      ),
      data: (doc) {
        final balance = ref.watch(walletBalanceProvider);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'My Wallet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Balance card
                  _BalanceCard(
                    balance: balance,
                    onTopUp: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TopUpScreen(),
                      ),
                    ).then((_) {
                      ref.invalidate(userStreamProvider);
                      ref.invalidate(walletBalanceProvider);
                    }),
                    onWithdraw: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WithdrawScreen(balance: balance),
                      ),
                    ).then((_) {
                      ref.invalidate(userStreamProvider);
                      ref.invalidate(walletBalanceProvider);
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Stats
                  _StatsRow(
                    transactionsAsync: transactionsAsync,
                  ),
                  const SizedBox(height: 28),

                  // Transactions header
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Transaction list
                  transactionsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                    error: (_, __) => const SizedBox(),
                    data: (snapshot) {
                      if (snapshot == null ||
                          snapshot.docs.isEmpty) {
                        return _EmptyTransactions();
                      }
                      return Column(
                        children:
                            snapshot.docs.map((doc) {
                          final d = doc.data()
                              as Map<String, dynamic>;
                          final amount =
                              (d['amount'] ?? 0.0)
                                  .toDouble();
                          final isCredit = amount > 0;
                          return TransactionItem(
                            data: TransactionData(
                              icon: isCredit
                                  ? Icons
                                      .arrow_downward_rounded
                                  : Icons
                                      .arrow_upward_rounded,
                              iconColor: isCredit
                                  ? AppColors.success
                                  : AppColors.error,
                              iconBg: isCredit
                                  ? AppColors.accentLighter
                                  : const Color(0xFFFCEBEB),
                              title: d['type'] ?? '',
                              subtitle:
                                  d['description'] ?? '',
                              amount:
                                  '${isCredit ? '+' : ''}KES ${amount.abs().toStringAsFixed(0)}',
                              amountColor: isCredit
                                  ? AppColors.success
                                  : AppColors.error,
                              time: _formatTime(
                                  d['createdAt']
                                      as Timestamp?),
                              status: 'Completed',
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final time = timestamp.toDate();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

// ── Empty Transactions ──
class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLighter),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.receipt_long_outlined,
            color: AppColors.greyLight,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Top up your wallet to get started.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Balance Card ──
class _BalanceCard extends StatefulWidget {
  final double balance;
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;

  const _BalanceCard({
    required this.balance,
    required this.onTopUp,
    required this.onWithdraw,
  });

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _balanceVisible = true;

  String _formatBalance(double balance) {
    return balance.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () => setState(
                    () => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _balanceVisible
                ? 'KES ${_formatBalance(widget.balance)}'
                : 'KES ••••••',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onTopUp,
                  icon: const Icon(Icons.add_rounded,
                      size: 18),
                  label: const Text('Top Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onWithdraw,
                  icon: const Icon(
                      Icons.arrow_upward_rounded,
                      size: 18),
                  label: const Text('Withdraw'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(
                      color: Colors.white54,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ──
class _StatsRow extends StatelessWidget {
  final AsyncValue transactionsAsync;

  const _StatsRow({required this.transactionsAsync});

  @override
  Widget build(BuildContext context) {
    return transactionsAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (snapshot) {
        double totalIn = 0;
        double totalOut = 0;

        if (snapshot != null) {
          for (final doc in snapshot.docs) {
            final data =
                doc.data() as Map<String, dynamic>;
            final amount =
                (data['amount'] ?? 0.0).toDouble();
            if (amount > 0) {
              totalIn += amount;
            } else {
              totalOut += amount.abs();
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total In',
                amount:
                    'KES ${totalIn.toStringAsFixed(0)}',
                icon: Icons.arrow_downward_rounded,
                color: AppColors.success,
                bg: AppColors.accentLighter,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Total Out',
                amount:
                    'KES ${totalOut.toStringAsFixed(0)}',
                icon: Icons.arrow_upward_rounded,
                color: AppColors.error,
                bg: const Color(0xFFFCEBEB),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLighter),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}