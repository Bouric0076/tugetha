import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Groups',
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
                        builder: (_) => const CreateGroupScreen(),
                      ),
                    ).then((_) => ref.invalidate(groupsProvider)),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
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

            // Content
            Expanded(
              child: groupsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error loading groups.\nPlease try again.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.grey,
                    ),
                  ),
                ),
                data: (snapshot) {
                  if (snapshot == null || snapshot.docs.isEmpty) {
                    return _EmptyGroups(
                      onCreateTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateGroupScreen(),
                        ),
                      ).then(
                          (_) => ref.invalidate(groupsProvider)),
                    );
                  }

                  final groups = snapshot.docs;

                  return Column(
                    children: [
                      // Stats bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: _GroupStatsBar(groups: groups),
                      ),
                      const SizedBox(height: 20),

                      // Groups list
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          itemCount: groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, i) {
                            final data = groups[i].data()
                                as Map<String, dynamic>;
                            final groupId = groups[i].id;
                            return _GroupCard(
                              groupId: groupId,
                              data: data,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GroupDetailScreen(
                                    groupId: groupId,
                                    data: data,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──
class _EmptyGroups extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyGroups({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No groups yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a group with friends to start saving towards shared goals together.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                fontFamily: 'Poppins',
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create your first group'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Bar ──
class _GroupStatsBar extends StatelessWidget {
  final List<QueryDocumentSnapshot> groups;
  const _GroupStatsBar({required this.groups});

  @override
  Widget build(BuildContext context) {
    int totalMembers = 0;
    for (final g in groups) {
      final data = g.data() as Map<String, dynamic>;
      final members = data['members'] as List? ?? [];
      totalMembers += members.length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLighter),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Groups',
            value: '${groups.length}',
            icon: Icons.group_outlined,
            color: AppColors.primary,
          ),
          _VerticalDivider(),
          _StatItem(
            label: 'Members',
            value: '$totalMembers',
            icon: Icons.people_outline_rounded,
            color: AppColors.accent,
          ),
          _VerticalDivider(),
          _StatItem(
            label: 'Goals',
            value: '—',
            icon: Icons.flag_outlined,
            color: const Color(0xFF185FA5),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
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

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.greyLighter,
    );
  }
}

// ── Group Card ──
class _GroupCard extends StatelessWidget {
  final String groupId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _GroupCard({
    required this.groupId,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final members = data['members'] as List? ?? [];
    final name = data['name'] ?? 'Group';
    final emoji = data['emoji'] ?? '🤝';
    final color = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyLighter),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 13,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${members.length} member${members.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to view goals & activity',
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.7),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.greyLight,
            ),
          ],
        ),
      ),
    );
  }
}