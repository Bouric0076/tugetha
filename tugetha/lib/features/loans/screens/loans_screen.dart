import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../services/auth_service.dart';
import 'request_loan_screen.dart';
import 'loan_detail_screen.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() =>
      _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borrowingAsync = ref.watch(borrowingLoansProvider);
    final lendingAsync = ref.watch(lendingLoansProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Loans',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RequestLoanScreen(),
                      ),
                    ).then((_) {
                      ref.invalidate(borrowingLoansProvider);
                      ref.invalidate(lendingLoansProvider);
                    }),
                    icon: const Icon(Icons.add_rounded,
                        size: 18),
                    label: const Text('Request'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: _LoanSummary(
                borrowingAsync: borrowingAsync,
                lendingAsync: lendingAsync,
              ),
            ),
            const SizedBox(height: 20),

            // Tabs
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.greyLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.grey,
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Borrowing'),
                    Tab(text: 'Lending'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LoanList(
                    loansAsync: borrowingAsync,
                    isBorrowing: true,
                    emptyMessage:
                        'No active loans.\nRequest one from a friend!',
                  ),
                  _LoanList(
                    loansAsync: lendingAsync,
                    isBorrowing: false,
                    emptyMessage:
                        'You haven\'t lent to anyone yet.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loan Summary ──
class _LoanSummary extends StatelessWidget {
  final AsyncValue borrowingAsync;
  final AsyncValue lendingAsync;

  const _LoanSummary({
    required this.borrowingAsync,
    required this.lendingAsync,
  });

  double _calcTotal(AsyncValue async) {
    return async.when(
      data: (snapshot) {
        if (snapshot == null) return 0.0;
        double total = 0;
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 'active') {
            total +=
                (data['remaining'] ?? 0.0).toDouble();
          }
        }
        return total;
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalOwed = _calcTotal(borrowingAsync);
    final totalLent = _calcTotal(lendingAsync);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'I Owe',
            amount: totalOwed,
            icon: Icons.arrow_upward_rounded,
            color: AppColors.error,
            bg: const Color(0xFFFCEBEB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Owed to Me',
            amount: totalLent,
            icon: Icons.arrow_downward_rounded,
            color: AppColors.success,
            bg: AppColors.accentLighter,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final Color bg;

  const _SummaryCard({
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
                'KES ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
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

// ── Loan List ──
class _LoanList extends StatelessWidget {
  final AsyncValue loansAsync;
  final bool isBorrowing;
  final String emptyMessage;

  const _LoanList({
    required this.loansAsync,
    required this.isBorrowing,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return loansAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
      error: (_, __) => Center(
        child: Text(
          'Error loading loans.\nPlease try again.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.grey,
          ),
        ),
      ),
      data: (snapshot) {
        if (snapshot == null || snapshot.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handshake_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      fontFamily: 'Poppins',
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: snapshot.docs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final doc = snapshot.docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _LoanCard(
              loanId: doc.id,
              data: data,
              isBorrowing: isBorrowing,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoanDetailScreen(
                    loanId: doc.id,
                    data: data,
                    isBorrowing: isBorrowing,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Loan Card ──
class _LoanCard extends StatefulWidget {
  final String loanId;
  final Map<String, dynamic> data;
  final bool isBorrowing;
  final VoidCallback onTap;

  const _LoanCard({
    required this.loanId,
    required this.data,
    required this.isBorrowing,
    required this.onTap,
  });

  @override
  State<_LoanCard> createState() => _LoanCardState();
}

class _LoanCardState extends State<_LoanCard> {
  String _otherName = 'User';

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    final uid = widget.isBorrowing
        ? widget.data['lenderId']
        : widget.data['borrowerId'];
    if (uid == null) return;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted && userData.exists) {
      setState(() {
        _otherName = userData.data()?['name'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount =
        (widget.data['amount'] ?? 0.0).toDouble();
    final remaining =
        (widget.data['remaining'] ?? 0.0).toDouble();
    final status = widget.data['status'] ?? 'pending';
    final progress = amount > 0
        ? ((amount - remaining) / amount).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = status == 'completed';
    final isPending = status == 'pending';

    Color statusColor;
    Color statusBg;
    String statusLabel;

    if (isCompleted) {
      statusColor = AppColors.success;
      statusBg = AppColors.accentLighter;
      statusLabel = 'Completed';
    } else if (isPending) {
      statusColor = const Color(0xFF185FA5);
      statusBg = const Color(0xFFE6F1FB);
      statusLabel = 'Pending';
    } else {
      statusColor = AppColors.warning;
      statusBg = const Color(0xFFFAEEDA);
      statusLabel = 'Active';
    }

    final initials = _otherName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLighter),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLighter,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isBorrowing
                            ? 'From $_otherName'
                            : 'To $_otherName',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        widget.data['purpose'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.greyLighter,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isBorrowing
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted
                          ? 'Total amount'
                          : 'Remaining',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'KES ${(isCompleted ? amount : remaining).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.success
                            : widget.isBorrowing
                                ? AppColors.error
                                : AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                if (isPending && !widget.isBorrowing)
                  _ApproveBadge(
                    loanId: widget.loanId,
                    data: widget.data,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Approve Badge (for lender on pending loans) ──
class _ApproveBadge extends StatefulWidget {
  final String loanId;
  final Map<String, dynamic> data;

  const _ApproveBadge({
    required this.loanId,
    required this.data,
  });

  @override
  State<_ApproveBadge> createState() => _ApproveBadgeState();
}

class _ApproveBadgeState extends State<_ApproveBadge> {
  bool _loading = false;

  void _approve() async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('loans')
          .doc(widget.loanId)
          .update({'status': 'approved'});

      // Call Cloud Function to disburse
      // We'll wire this in the next step
      // For now just update status
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Loan approved! Disbursement processing...',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _approve,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Approve',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }
}