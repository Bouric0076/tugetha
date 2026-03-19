import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'change_pin_screen.dart';
import 'kyc_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error loading profile')),
      ),
      data: (doc) {
        final data = doc?.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? 'User';
        final phone = AuthService.currentUser?.phoneNumber ?? '';
        final balance =
            (data?['walletBalance'] ?? 0.0).toDouble();
        final trustScore = data?['trustScore'] ?? 50;
        final kycStatus = data?['kycStatus'] ?? 'pending';
        final createdAt = data?['createdAt'] as Timestamp?;
        final memberSince = createdAt != null
            ? _formatMemberSince(createdAt.toDate())
            : 'Recently';

        final initials = name
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  _ProfileHeader(
                    name: name,
                    phone: phone,
                    initials: initials,
                    memberSince: memberSince,
                  ),
                  const SizedBox(height: 8),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: _StatsRow(
                      balance: balance,
                      ref: ref,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Trust score
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: _TrustScoreCard(
                      score: trustScore,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Account'),
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                name: name,
                                mpesaNumber: data?['mpesaNumber'] ?? '',
                              ),
                            ),
                          ).then((_) => ref.invalidate(userStreamProvider)),
                        ),
                        _MenuItem(
                          icon: Icons.phone_outlined,
                          label: 'M-Pesa Number',
                          trailing:
                              data?['mpesaNumber'] ?? phone,
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.verified_outlined,
                          label: 'KYC Verification',
                          trailing: kycStatus == 'verified'
                              ? 'Verified'
                              : 'Pending',
                          trailingColor:
                              kycStatus == 'verified'
                                  ? AppColors.success
                                  : AppColors.warning,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const KycScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _SectionLabel('Security'),
                        _MenuItem(
                          icon: Icons.lock_outline_rounded,
                          label: 'Change PIN',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ChangePinScreen(),
                            ),
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.fingerprint_rounded,
                          label: 'Biometric Login',
                          isToggle: true,
                          toggleValue: false,
                          onToggle: (_) {},
                        ),
                        _MenuItem(
                          icon: Icons.devices_outlined,
                          label: 'Trusted Devices',
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),

                        _SectionLabel('Notifications'),
                        _NotificationToggle(
                          uid: AuthService
                                  .currentUser?.uid ??
                              '',
                          preferences:
                              data?['notificationPrefs']
                                  as Map<String, dynamic>?,
                        ),
                        const SizedBox(height: 20),

                        _SectionLabel('Support'),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Help & FAQ',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.policy_outlined,
                          label: 'Privacy Policy',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.description_outlined,
                          label: 'Terms of Service',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.star_outline_rounded,
                          label: 'Rate Tugetha',
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),

                        _SignOutButton(),
                        const SizedBox(height: 12),

                        Center(
                          child: Text(
                            'Tugetha v1.0.0 • by Sinaps Technology',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.greyLight,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatMemberSince(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ── Profile Header ──
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String initials;
  final String memberSince;

  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.initials,
    required this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phone,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Member since $memberSince',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ──
class _StatsRow extends ConsumerWidget {
  final double balance;
  final WidgetRef ref;

  const _StatsRow({
    required this.balance,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);
    final borrowingAsync = ref.watch(borrowingLoansProvider);
    final lendingAsync = ref.watch(lendingLoansProvider);

    final groupCount = groupsAsync.when(
      data: (s) => s?.docs.length ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final loanCount = borrowingAsync.when(
          data: (s) => s?.docs.length ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        ) +
        lendingAsync.when(
          data: (s) => s?.docs.length ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );

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
            value: '$groupCount',
            label: 'Groups',
          ),
          _Divider(),
          _StatItem(
            value: 'KES ${balance.toStringAsFixed(0)}',
            label: 'Wallet',
          ),
          _Divider(),
          _StatItem(
            value: '$loanCount',
            label: 'Loans',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 2),
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.greyLighter,
    );
  }
}

// ── Trust Score Card ──
class _TrustScoreCard extends StatelessWidget {
  final int score;
  const _TrustScoreCard({required this.score});

  String get _label {
    if (score >= 90) return 'Excellent Borrower';
    if (score >= 75) return 'Trusted Borrower';
    if (score >= 60) return 'Good Standing';
    if (score >= 40) return 'Building Trust';
    return 'New Member';
  }

  Color get _color {
    if (score >= 75) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withOpacity(0.08),
            _color.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _color,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _color,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Trust Score',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified_rounded,
                      color: _color,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.white,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Toggles ──
class _NotificationToggle extends StatefulWidget {
  final String uid;
  final Map<String, dynamic>? preferences;

  const _NotificationToggle({
    required this.uid,
    required this.preferences,
  });

  @override
  State<_NotificationToggle> createState() =>
      _NotificationToggleState();
}

class _NotificationToggleState
    extends State<_NotificationToggle> {
  late bool _push;
  late bool _sms;
  late bool _email;

  @override
  void initState() {
    super.initState();
    _push = widget.preferences?['push'] ?? true;
    _sms = widget.preferences?['sms'] ?? true;
    _email = widget.preferences?['email'] ?? false;
  }

  Future<void> _updatePref(String key, bool value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'notificationPrefs.$key': value});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.notifications_outlined,
          label: 'Push Notifications',
          isToggle: true,
          toggleValue: _push,
          onToggle: (val) {
            setState(() => _push = val);
            _updatePref('push', val);
          },
        ),
        _MenuItem(
          icon: Icons.sms_outlined,
          label: 'SMS Alerts',
          isToggle: true,
          toggleValue: _sms,
          onToggle: (val) {
            setState(() => _sms = val);
            _updatePref('sms', val);
          },
        ),
        _MenuItem(
          icon: Icons.email_outlined,
          label: 'Email Notifications',
          isToggle: true,
          toggleValue: _email,
          onToggle: (val) {
            setState(() => _email = val);
            _updatePref('email', val);
          },
        ),
      ],
    );
  }
}

// ── Section Label ──
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
          fontFamily: 'Poppins',
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Menu Item ──
class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? trailingColor;
  final bool isToggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.trailingColor,
    this.isToggle = false,
    this.toggleValue = false,
    this.onToggle,
    this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.toggleValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isToggle ? null : widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.greyLighter),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (widget.isToggle)
              Switch(
                value: _value,
                onChanged: (val) {
                  setState(() => _value = val);
                  widget.onToggle?.call(val);
                },
                activeColor: AppColors.primary,
              )
            else if (widget.trailing != null)
              Text(
                widget.trailing!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.trailingColor ??
                      AppColors.grey,
                  fontFamily: 'Poppins',
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.greyLight,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Sign Out Button ──
class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSignOutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCEBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.error.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of Tugetha?',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.grey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  ),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ── Sign Out Redirect ──
class _SignOutRedirect extends StatefulWidget {
  const _SignOutRedirect();

  @override
  State<_SignOutRedirect> createState() =>
      _SignOutRedirectState();
}

class _SignOutRedirectState extends State<_SignOutRedirect> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const _OnboardingPlaceholder(),
          ),
          (_) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _OnboardingPlaceholder extends StatelessWidget {
  const _OnboardingPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Import and use your actual OnboardingScreen
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Signed out successfully',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.grey,
          ),
        ),
      ),
    );
  }
}