import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/paystack_service.dart';
import '../../../services/wallet_service.dart';

class LoanDetailScreen extends StatefulWidget {
  final String loanId;
  final Map<String, dynamic> data;
  final bool isBorrowing;

  const LoanDetailScreen({
    super.key,
    required this.loanId,
    required this.data,
    required this.isBorrowing,
  });

  @override
  State<LoanDetailScreen> createState() =>
      _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  String _otherName = 'User';
  bool _isLoading = false;

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
    final userData = await FirestoreService.getUser(uid);
    if (mounted) {
      setState(() {
        _otherName = userData?['name'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('loans')
          .doc(widget.loanId)
          .snapshots(),
      builder: (context, snapshot) {
        final loanData = snapshot.hasData &&
                snapshot.data!.exists
            ? snapshot.data!.data() as Map<String, dynamic>
            : widget.data;

        final amount =
            (loanData['amount'] ?? 0.0).toDouble();
        final remaining =
            (loanData['remaining'] ?? 0.0).toDouble();
        final status = loanData['status'] ?? 'pending';
        final isCompleted = status == 'completed';
        final isPending = status == 'pending';
        final progress = amount > 0
            ? ((amount - remaining) / amount)
                .clamp(0.0, 1.0)
            : 0.0;
        final pct =
            (progress * 100).toStringAsFixed(0);
        final fee = (loanData['fee'] ?? 0.0).toDouble();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Loan Details'),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isBorrowing
                            ? [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ]
                            : [
                                AppColors.accent,
                                AppColors.accentLight,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              Colors.white.withOpacity(0.2),
                          child: Text(
                            _otherName
                                .split(' ')
                                .map((e) =>
                                    e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.isBorrowing
                              ? 'Borrowed from $_otherName'
                              : 'Lent to $_otherName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          loanData['purpose'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'KES ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Text(
                          'Total loan amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pending approval banner
                  if (isPending && !widget.isBorrowing)
                    _ApproveBanner(
                      loanId: widget.loanId,
                      loanData: loanData,
                      lenderName: _otherName,
                    ),

                  // Progress
                  if (!isCompleted && !isPending) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.greyLighter),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              const Text(
                                'Repayment Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor:
                                  AppColors.greyLighter,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _DetailStat(
                                label: 'Paid',
                                value:
                                    'KES ${(amount - remaining).toStringAsFixed(0)}',
                                color: AppColors.success,
                              ),
                              _DetailStat(
                                label: 'Remaining',
                                value:
                                    'KES ${remaining.toStringAsFixed(0)}',
                                color: AppColors.error,
                              ),
                              _DetailStat(
                                label: 'Period',
                                value: loanData[
                                        'repaymentPeriod'] ??
                                    '—',
                                color: AppColors.dark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Loan info table
                  const Text(
                    'Loan Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoTable(rows: [
                    ['Status', status.toUpperCase()],
                    ['Purpose', loanData['purpose'] ?? '—'],
                    [
                      'Repayment period',
                      loanData['repaymentPeriod'] ?? '—'
                    ],
                    [
                      'Facilitation fee',
                      'KES ${fee.toStringAsFixed(0)} (2.5%)'
                    ],
                    [
                      'Amount disbursed',
                      'KES ${(amount - fee).toStringAsFixed(0)}'
                    ],
                  ]),
                  const SizedBox(height: 24),

                  // Repay button
                  if (widget.isBorrowing && !isCompleted && !isPending)
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _showRepaySheet(
                              context, remaining, loanData),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Make a Repayment'),
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

  void _showRepaySheet(
    BuildContext context,
    double remaining,
    Map<String, dynamic> loanData,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make a Repayment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Remaining: KES ${remaining.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _RepayOption(
                    label: 'Half',
                    amount:
                        'KES ${(remaining / 2).toStringAsFixed(0)}',
                    onTap: () => _repay(
                      context,
                      remaining / 2,
                      loanData,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RepayOption(
                    label: 'Full Remaining',
                    amount:
                        'KES ${remaining.toStringAsFixed(0)}',
                    onTap: () =>
                        _repay(context, remaining, loanData),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _repay(
    BuildContext context,
    double amount,
    Map<String, dynamic> loanData,
  ) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final lenderUid = loanData['lenderId'];

      // 1. Initialize split payment (Borrower pays Lender)
      final data = await PaystackService.initializePayment(
        phone: user.phoneNumber ?? '',
        amount: amount,
        receiverUid: lenderUid,
      );

      if (data == null || data['reference'] == null) {
        throw Exception('Failed to initialize repayment');
      }

      final reference = data['reference'];

      if (mounted) {
        setState(() => _isLoading = false);
        
        // 2. Wait for STK Push and verification
        await PaystackService.waitForStkPush(
          context: context,
          reference: reference,
          onCompleted: (success) async {
            if (success) {
              // 3. Update loan balance in Firestore
              final currentRemaining = (loanData['remaining'] ?? 0.0).toDouble();
              final newRemaining = currentRemaining - amount;
              
              await FirebaseFirestore.instance
                  .collection('loans')
                  .doc(widget.loanId)
                  .update({
                'remaining': newRemaining,
                'status': newRemaining <= 0 ? 'completed' : 'active',
                'lastRepaymentDate': FieldValue.serverTimestamp(),
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Repayment successful!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Repayment failed or timed out.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception:', '').trim(),
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ── Approve Banner ──
class _ApproveBanner extends StatefulWidget {
  final String loanId;
  final Map<String, dynamic> loanData;
  final String lenderName;

  const _ApproveBanner({
    required this.loanId,
    required this.loanData,
    required this.lenderName,
  });

  @override
  State<_ApproveBanner> createState() =>
      _ApproveBannerState();
}

class _ApproveBannerState extends State<_ApproveBanner> {
  bool _loading = false;

  Future<void> _approve() async {
    setState(() => _loading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final amount = (widget.loanData['amount'] ?? 0.0).toDouble();
      final borrowerUid = widget.loanData['borrowerId'];

      // 1. Initialize split payment (Lender pays Borrower)
      final data = await PaystackService.initializePayment(
        phone: user.phoneNumber ?? '',
        amount: amount,
        receiverUid: borrowerUid,
      );

      if (data == null || data['reference'] == null) {
        throw Exception('Failed to initialize disbursement');
      }

      final reference = data['reference'];

      if (mounted) {
        setState(() => _loading = false);
        
        // 2. Wait for STK Push and verification
        await PaystackService.waitForStkPush(
          context: context,
          reference: reference,
          onCompleted: (success) async {
            if (success) {
              // 3. Update loan status in Firestore
              await FirebaseFirestore.instance
                  .collection('loans')
                  .doc(widget.loanId)
                  .update({
                'status': 'active',
                'disbursedAt': FieldValue.serverTimestamp(),
                'paymentReference': reference,
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Loan disbursed successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disbursement failed or timed out.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception:', '').trim(),
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _decline() async {
    await FirebaseFirestore.instance
        .collection('loans')
        .doc(widget.loanId)
        .update({'status': 'declined'});
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF185FA5).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.pending_outlined,
                color: Color(0xFF185FA5),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Awaiting your approval',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF185FA5),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Review this loan request and approve or decline it.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey,
              fontFamily: 'Poppins',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _approve,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Approve & Disburse'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : _decline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(
                        color: AppColors.error),
                  ),
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ──
class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

class _InfoTable extends StatelessWidget {
  final List<List<String>> rows;
  const _InfoTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyLighter),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: i < rows.length - 1
                  ? const Border(
                      bottom: BorderSide(
                        color: AppColors.greyLighter,
                      ),
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row[0],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  row[1],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RepayOption extends StatelessWidget {
  final String label;
  final String amount;
  final VoidCallback onTap;

  const _RepayOption({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryLight,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}