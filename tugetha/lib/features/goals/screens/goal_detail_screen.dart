import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/wallet_service.dart';
import '../../../services/paystack_service.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  final String groupId;
  final Map<String, dynamic> data;

  const GoalDetailScreen({
    super.key,
    required this.goalId,
    required this.groupId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('goals')
          .doc(goalId)
          .snapshots(),
      builder: (context, snapshot) {
        final goalData = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!.data() as Map<String, dynamic>
            : data;

        final title = goalData['title'] ?? 'Goal';
        final current =
            (goalData['currentAmount'] ?? 0.0).toDouble();
        final target =
            (goalData['targetAmount'] ?? 0.0).toDouble();
        final progress =
            target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
        final pct = (progress * 100).toStringAsFixed(0);
        final deadline = goalData['deadline'] != null
            ? (goalData['deadline'] as Timestamp).toDate()
            : null;
        final daysLeft = deadline != null
            ? deadline.difference(DateTime.now()).inDays
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          goalData['category']
                                  ?.split(' ')
                                  .first ??
                              '🎯',
                          style: const TextStyle(
                              fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          goalData['category'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Progress card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.greyLighter),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  'KES ${current.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: AppColors.primary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: AppColors.accent,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  'raised so far',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  'of KES ${target.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                  MainAxisAlignment
                                      .spaceAround,
                              children: [
                                _GoalStat(
                                  label: 'Remaining',
                                  value:
                                      'KES ${(target - current).toStringAsFixed(0)}',
                                  icon: Icons.savings_outlined,
                                ),
                                _GoalStat(
                                  label: 'Deadline',
                                  value: deadline != null
                                      ? '${deadline.day}/${deadline.month}/${deadline.year}'
                                      : '—',
                                  icon: Icons
                                      .calendar_today_outlined,
                                ),
                                _GoalStat(
                                  label: 'Days left',
                                  value: daysLeft != null
                                      ? '$daysLeft days'
                                      : '—',
                                  icon: Icons.timer_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contribute button
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showContributeSheet(
                                context, groupId, goalId),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Contribute Now'),
                      ),
                      const SizedBox(height: 28),

                      // Contributions
                      const Text(
                        'Contributions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ContributionsList(
                        groupId: groupId,
                        goalId: goalId,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContributeSheet(
    BuildContext context,
    String groupId,
    String goalId,
  ) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contribute to Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Amount will be deducted from your wallet.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                  fontFamily: 'Poppins',
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(left: 16, right: 8),
                    child: Text(
                      'KES',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [100, 500, 1000, 2000].map((a) =>
                  GestureDetector(
                    onTap: () =>
                        controller.text = a.toString(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Text(
                        'KES $a',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final amount =
                      double.tryParse(controller.text);
                  if (amount == null || amount <= 0) return;

                  final user = AuthService.currentUser;
                  if (user == null) return;

                  try {
                    // 1. Initialize contribution via Django
                    final result = await WalletService.contributeToGoal(
                      groupId: groupId,
                      goalId: goalId,
                      amount: amount,
                    );

                    if (result['success'] != true) {
                      throw Exception(result['message'] ?? 'Failed to initialize contribution');
                    }

                    final reference = result['reference'];

                    if (context.mounted) {
                      Navigator.pop(context); // Close amount sheet
                      
                      // 2. Wait for STK Push and verification
                      await PaystackService.waitForStkPush(
                        context: context,
                        reference: reference,
                        onCompleted: (success) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'KES ${amount.toStringAsFixed(0)} contributed successfully!',
                                  style: const TextStyle(fontFamily: 'Poppins'),
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contribution verification failed or timed out.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Contribution failed: ${e.toString().replaceAll('Exception:', '').trim()}',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Confirm Contribution'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _GoalStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.grey, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.grey,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

// ── Contributions List ──
class _ContributionsList extends StatelessWidget {
  final String groupId;
  final String goalId;

  const _ContributionsList({
    required this.groupId,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('goals')
          .doc(goalId)
          .collection('contributions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.greyLighter),
            ),
            child: const Center(
              child: Text(
                'No contributions yet.\nBe the first to contribute!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final amount =
                (d['amount'] ?? 0.0).toDouble();
            final userId = d['userId'] ?? '';
            final isMe =
                userId == AuthService.currentUser?.uid;

            return FutureBuilder<Map<String, dynamic>?>(
              future: FirestoreService.getUser(userId),
              builder: (context, userSnapshot) {
                final name =
                    userSnapshot.data?['name'] ?? 'User';
                final initials = name
                    .split(' ')
                    .map((e) => e.isNotEmpty ? e[0] : '')
                    .take(2)
                    .join()
                    .toUpperCase();

                final timestamp =
                    d['createdAt'] as Timestamp?;
                final time = timestamp != null
                    ? _formatTime(timestamp)
                    : '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.greyLighter),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isMe
                            ? AppColors.primary
                            : AppColors.primaryLighter,
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isMe
                                ? Colors.white
                                : AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isMe ? 'You' : name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            'KES ${amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
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
              },
            );
          }).toList(),
        );
      },
    );
  }

  String _formatTime(Timestamp timestamp) {
    final now = DateTime.now();
    final time = timestamp.toDate();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}