import os

replacements = {
    "lib/features/auth/screens/phone_auth_screen.dart": [
        (
"""        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: _fullPhone,
              verificationId: verificationId,
            ),
          ),
        );""", 
"""        context.push('/otp', extra: {
          'phoneNumber': _fullPhone,
          'verificationId': verificationId,
        });"""
        )
    ],
    "lib/features/auth/screens/pin_setup_screen.dart": [
        (
"""          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );""",
"""          context.go('/home');"""
        )
    ],
    "lib/features/onboarding/screens/onboarding_screen.dart": [
        (
"""    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );""",
"""    context.go('/phoneAuth');"""
        )
    ],
    "lib/features/splash/screens/splash_screen.dart": [
        (
"""      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );""",
"""      context.go('/onboarding');"""
        ),
        (
"""      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );""",
"""      context.go('/home');"""
        ),
        (
"""      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        ),
      );""",
"""      context.go('/profileSetup');"""
        )
    ],
    "lib/features/home/widgets/home_tab.dart": [
        (
"""                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletScreen()),
                ),""",
"""                onTap: () => context.push('/wallet'),"""
        ),
        (
"""        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),""",
"""        onTap: () => context.push('/createGroup'),"""
        ),
        (
"""        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
        ),""",
"""        onTap: () => context.push('/createGoal'),"""
        ),
        (
"""        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RequestLoanScreen()),
        ),""",
"""        onTap: () => context.push('/requestLoan'),"""
        ),
        (
"""            onButtonPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
            ),""",
"""            onButtonPressed: () => context.push('/createGoal'),"""
        ),
        (
"""            onButtonPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            ),""",
"""            onButtonPressed: () => context.push('/wallet'),"""
        )
    ],
    "lib/features/groups/screens/groups_screen.dart": [
        (
"""                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GroupDetailScreen(
                                    groupId: groupId,
                                    data: data,
                                  ),
                                ),
                              ),""",
"""                              onTap: () => context.push('/groupDetail', extra: {'groupId': groupId, 'data': data}),"""
        )
    ],
    "lib/features/groups/screens/group_detail_screen.dart": [
        (
"""                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateGoalScreen(
                              groupId: groupId,
                            ),
                          ),
                        ),""",
"""                        onPressed: () => context.push('/createGoal', extra: groupId),"""
        ),
        (
"""              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoalDetailScreen(
                    goalId: doc.id,
                    groupId: groupId,
                    data: data,
                  ),
                ),
              ),""",
"""              onTap: () => context.push('/goalDetail', extra: {'goalId': doc.id, 'groupId': groupId, 'data': data}),"""
        )
    ],
    "lib/features/loans/screens/loans_screen.dart": [
        (
"""              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoanDetailScreen(
                    loanId: doc.id,
                    data: data,
                  ),
                ),
              ),""",
"""              onTap: () => context.push('/loanDetail', extra: {'loanId': doc.id, 'data': data}),"""
        )
    ],
    "lib/features/profile/screens/profile_screen.dart": [
        (
"""                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          ),""",
"""                          onTap: () => context.push('/editProfile'),"""
        ),
        (
"""                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PhoneAuthScreen(),
                  ),
                  (_) => false,
                );""",
"""                context.go('/phoneAuth');"""
        ),
        (
"""        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const PhoneAuthScreen(),
          ),
          (_) => false,
        );""",
"""        context.go('/phoneAuth');"""
        )
    ]
}

for file, replaces in replacements.items():
    if os.path.exists(file):
        with open(file, 'r') as f:
            content = f.read()
        
        # also add go_router
        if 'package:go_router/go_router.dart' not in content:
            content = "import 'package:go_router/go_router.dart';\n" + content
            
        for target, replacement in replaces:
            content = content.replace(target, replacement)
            
        with open(file, 'w') as f:
            f.write(content)
        print(f"Updated {file}")
