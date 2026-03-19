import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../groups/screens/create_group_screen.dart';
import '../../goals/screens/create_goal_screen.dart';
import '../../loans/screens/request_loan_screen.dart';

import '../../wallet/screens/wallet_screen.dart';
import '../../wallet/screens/topup_screen.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Hello'; // Late night/Early morning
    }
  }

  String _formatBalance(double balance) {
    return balance.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _showComingSoon(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature is currently under development.\nStay tuned for updates!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);

    return userStream.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
      error: (e, _) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Something went wrong.\nPlease restart the app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.grey,
            ),
          ),
        ),
      ),
      data: (doc) {
        final balance = ref.watch(walletBalanceProvider);
        final data = doc?.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? 'User';
        final firstName = name.split(' ')[0];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userStreamProvider);
                ref.invalidate(walletBalanceProvider);
                ref.invalidate(groupsProvider);
                ref.invalidate(transactionsProvider);
                return Future.delayed(
                    const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Top bar
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()} 👋',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            firstName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.greyLighter,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.dark,
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 21,
                            backgroundColor:
                                AppColors.primaryLighter,
                            child: Text(
                              name.isNotEmpty
                                  ? name
                                      .split(' ')
                                      .map((e) => e[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Wallet card
                  _WalletCard(
                    balance: balance,
                    formatBalance: _formatBalance,
                    showComingSoon: _showComingSoon,
                  ),
                  const SizedBox(height: 28),

                  // Quick actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _QuickActions(
                    balance: balance,
                    showComingSoon: _showComingSoon,
                  ),
                  const SizedBox(height: 28),

                  // Active goals
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ActiveGoals(),
                  const SizedBox(height: 28),

                  // Recent activity
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RecentActivity(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLighter),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onButtonPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wallet Card ──
class _WalletCard extends StatefulWidget {
  final double balance;
  final String Function(double) formatBalance;
  final void Function(BuildContext) showComingSoon;

  const _WalletCard({
    required this.balance,
    required this.formatBalance,
    required this.showComingSoon,
  });

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  bool _balanceVisible = true;

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
                'Wallet Balance',
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
                ? 'KES ${widget.formatBalance(widget.balance)}'
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
              _WalletAction(
                icon: Icons.add_rounded,
                label: 'Top Up',
                onTap: () => widget.showComingSoon(context),
              ),
              const SizedBox(width: 12),
              _WalletAction(
                icon: Icons.arrow_upward_rounded,
                label: 'Withdraw',
                onTap: () => widget.showComingSoon(context),
              ),
              const SizedBox(width: 12),
              _WalletAction(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ──
class _QuickActions extends StatelessWidget {
  final double balance;
  final void Function(BuildContext) showComingSoon;

  const _QuickActions({
    required this.balance,
    required this.showComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        icon: Icons.group_add_outlined,
        label: 'New Group',
        color: AppColors.primary,
        bg: AppColors.primaryLighter,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),
      ),
      _ActionData(
        icon: Icons.flag_outlined,
        label: 'New Goal',
        color: AppColors.accent,
        bg: AppColors.accentLighter,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
        ),
      ),
      _ActionData(
        icon: Icons.request_page_outlined,
        label: 'Request\nLoan',
        color: const Color(0xFF185FA5),
        bg: const Color(0xFFE6F1FB),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RequestLoanScreen()),
        ),
      ),
      _ActionData(
        icon: Icons.send_outlined,
        label: 'Send\nMoney',
        color: const Color(0xFF854F0B),
        bg: const Color(0xFFFAEEDA),
        onTap: () => showComingSoon(context),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions
          .map((a) => _ActionButton(data: a))
          .toList(),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });
}

class _ActionButton extends StatelessWidget {
  final _ActionData data;
  const _ActionButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: data.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(data.icon, color: data.color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.dark,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active Goals (real Firestore data) ──
class _ActiveGoals extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return groupsAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const SizedBox(),
      data: (snapshot) {
        if (snapshot == null || snapshot.docs.isEmpty) {
          return _EmptyStateCard(
            icon: Icons.flag_outlined,
            title: 'No active goals yet',
            description: 'Create a group and set a goal to start saving with your friends.',
            buttonLabel: 'Create New Goal',
            onButtonPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
            ),
          );
        }

        return Column(
          children: snapshot.docs.take(2).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GoalCard(
                title:
                    '${data['emoji'] ?? '🎯'} ${data['name']}',
                current: 0,
                target: 0,
                members:
                    (data['members'] as List?)?.length ?? 1,
                color: AppColors.primary,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final int members;
  final Color color;

  const _GoalCard({
    required this.title,
    required this.current,
    required this.target,
    required this.members,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? current / target : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$members members',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.greyLighter,
              valueColor:
                  AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KES ${current.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                target > 0
                    ? 'of KES ${target.toStringAsFixed(0)}'
                    : 'No target set',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
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

// ── Recent Activity (real Firestore data) ──
class _RecentActivity extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return transactionsAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const SizedBox(),
      data: (snapshot) {
        if (snapshot == null || snapshot.docs.isEmpty) {
          return _EmptyStateCard(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            description: 'Top up your wallet or send money to see your activity here.',
            buttonLabel: 'Top Up Wallet',
            onButtonPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TopUpScreen()),
            ),
          );
        }

        return Column(
          children: snapshot.docs.take(3).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] ?? '';
            final amount =
                (data['amount'] ?? 0.0).toDouble();
            final isCredit = amount > 0;

            return _ActivityItem(
              icon: isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              iconColor: isCredit
                  ? AppColors.success
                  : AppColors.error,
              iconBg: isCredit
                  ? AppColors.accentLighter
                  : const Color(0xFFFCEBEB),
              title: type,
              subtitle: data['description'] ?? '',
              amount:
                  '${isCredit ? '+' : ''}KES ${amount.abs().toStringAsFixed(0)}',
              amountColor: isCredit
                  ? AppColors.success
                  : AppColors.error,
              time: _formatTime(
                  data['createdAt'] as Timestamp?),
            );
          }).toList(),
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
    return '${diff.inDays} days ago';
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyLighter),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
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