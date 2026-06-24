import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/phone_auth_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/pin_setup_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/groups/screens/create_group_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/goals/screens/create_goal_screen.dart';
import '../../features/goals/screens/goal_detail_screen.dart';
import '../../features/loans/screens/request_loan_screen.dart';
import '../../features/loans/screens/loan_detail_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/change_pin_screen.dart';
import '../../features/wallet/screens/topup_screen.dart';
import '../../features/wallet/screens/withdraw_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/phoneAuth',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OtpScreen(
          phoneNumber: extra['phoneNumber'] as String,
          verificationId: extra['verificationId'] as String,
        );
      },
    ),
    GoRoute(
      path: '/pinSetup',
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      path: '/profileSetup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/createGroup',
      builder: (context, state) => const CreateGroupScreen(),
    ),
    GoRoute(
      path: '/groupDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return GroupDetailScreen(
          groupId: extra['groupId'] as String,
          data: extra['data'] as Map<String, dynamic>,
        );
      },
    ),
    GoRoute(
      path: '/createGoal',
      builder: (context, state) {
        final groupId = state.extra as String?;
        return CreateGoalScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/goalDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return GoalDetailScreen(
          goalId: extra['goalId'] as String,
          groupId: extra['groupId'] as String,
          data: extra['data'] as Map<String, dynamic>,
        );
      },
    ),
    GoRoute(
      path: '/requestLoan',
      builder: (context, state) => const RequestLoanScreen(),
    ),
    GoRoute(
      path: '/loanDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoanDetailScreen(
          loanId: extra['loanId'] as String,
          data: extra['data'] as Map<String, dynamic>,
          isBorrowing: extra['isBorrowing'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: '/editProfile',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return EditProfileScreen(
          name: extra?['name'] as String? ?? '',
          mpesaNumber: extra?['mpesaNumber'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/changePin',
      builder: (context, state) => const ChangePinScreen(),
    ),
    GoRoute(
      path: '/topup',
      builder: (context, state) => const TopUpScreen(),
    ),
    GoRoute(
      path: '/withdraw',
      builder: (context, state) => const WithdrawScreen(balance: 0.0),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletScreen(),
    ),
  ],
);
