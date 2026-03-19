import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import 'otp_screen.dart';
import 'pin_setup_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String get _fullPhone => '+254${_phoneController.text.trim()}';

  void _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await AuthService.sendOtp(
      phoneNumber: _fullPhone,
      onCodeSent: (verificationId) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: _fullPhone,
              verificationId: verificationId,
            ),
          ),
        );
      },
      onError: (error) {
        setState(() => _isLoading = false);
        final errorMessage = error.contains('BILLING_NOT_ENABLED')
            ? 'Something went wrong. Please try again later.'
            : error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      },
      onAutoVerified: (credential) async {
        final result = await FirebaseAuth.instance
            .signInWithCredential(credential);
        if (mounted && result.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PinSetupScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('T',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Welcome to\nTugetha 👋',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your phone number to get started.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 48),

                // Phone field label
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),

                // Phone input with +254 prefix
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark,
                  ),
                  decoration: InputDecoration(
                    hintText: '7XX XXX XXX',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.greyLight),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🇰🇪', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text('+254',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (val.length < 9) {
                      return 'Enter a valid Kenyan number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Hint
                const Text(
                  'We\'ll send a verification code to this number.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 48),

                // Continue button
                ElevatedButton(
                  onPressed: _isLoading ? null : _onContinue,
                  child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
                ),
                const SizedBox(height: 24),

                // Terms
                const Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing you agree to our ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                        fontFamily: 'Poppins',
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}