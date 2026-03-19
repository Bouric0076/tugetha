import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../goals/screens/create_goal_screen.dart';
import '../../goals/screens/goal_detail_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  final Map<String, dynamic> data;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Group';
    final emoji = data['emoji'] ?? '🤝';
    final members = data['members'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
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
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                ),
                onPressed: () => _showInviteSheet(context),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${members.length} member${members.length != 1 ? 's' : ''}',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Members
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _showInviteSheet(context),
                        icon: const Icon(
                          Icons.person_add_outlined,
                          size: 16,
                        ),
                        label: const Text('Invite'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MembersRow(
                    memberIds: members.cast<String>(),
                    onInviteTap: () =>
                        _showInviteSheet(context),
                  ),
                  const SizedBox(height: 28),

                  // Goals
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateGoalScreen(
                              groupId: groupId,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 16,
                        ),
                        label: const Text('New Goal'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Goals list from Firestore
                  _GoalsList(groupId: groupId),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    final inviteCode = groupId.substring(0, 8).toUpperCase();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Invite Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share this invite code with your friends',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    inviteCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: inviteCode),
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Invite code copied!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.copy_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Group ID for full invite link:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              groupId,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.greyLight,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text:
                        'Join my Tugetha group! Code: $inviteCode\nGroup ID: $groupId',
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Invite link copied!',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('Copy Invite Link'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Members Row ──
class _MembersRow extends StatefulWidget {
  final List<String> memberIds;
  final VoidCallback onInviteTap;

  const _MembersRow({
    required this.memberIds,
    required this.onInviteTap,
  });

  @override
  State<_MembersRow> createState() => _MembersRowState();
}

class _MembersRowState extends State<_MembersRow> {
  final Map<String, String> _memberNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    for (final uid in widget.memberIds) {
      final data = await FirestoreService.getUser(uid);
      if (data != null && mounted) {
        setState(() {
          _memberNames[uid] = data['name'] ?? 'User';
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 70,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...widget.memberIds.map((uid) {
            final name = _memberNames[uid] ?? 'User';
            final initials = name
                .split(' ')
                .map((e) => e.isNotEmpty ? e[0] : '')
                .take(2)
                .join()
                .toUpperCase();
            final isMe = uid == AuthService.currentUser?.uid;

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
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
                      if (isMe)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMe ? 'You' : name.split(' ')[0],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add member button
          Column(
            children: [
              GestureDetector(
                onTap: widget.onInviteTap,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.greyLighter,
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Invite',
                style: TextStyle(
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

// ── Goals List from Firestore ──
class _GoalsList extends StatelessWidget {
  final String groupId;
  const _GoalsList({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.goalsStream(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.greyLighter),
            ),
            child: Column(
              children: const [
                Icon(
                  Icons.flag_outlined,
                  color: AppColors.greyLight,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'No goals yet.\nTap "New Goal" to create one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final current =
                (data['currentAmount'] ?? 0.0).toDouble();
            final target =
                (data['targetAmount'] ?? 0.0).toDouble();
            final progress =
                target > 0 ? current / target : 0.0;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoalDetailScreen(
                    goalId: doc.id,
                    groupId: groupId,
                    data: data,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.greyLighter),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] ?? 'Goal',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.greyLighter,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'KES ${current.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
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
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}