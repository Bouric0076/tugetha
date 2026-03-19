import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import 'pin_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  void _onVerify() async {
    if (_otp.length < 6) return;
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    final result = await AuthService.verifyOtp(
      verificationId: widget.verificationId,
      otp: _otp,
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            for (var c in _controllers) c.clear();
            _focusNodes[0].requestFocus();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PinSetupScreen(),
        ),
      );
    }
  }

  void _onDigitEntered(int index, String val) {
    if (val.length > 1) {
      // Handle paste
      final digits = val.split('').where((s) => int.tryParse(s) != null).toList();
      for (int i = 0; i < digits.length && (index + i) < 6; i++) {
        _controllers[index + i].text = digits[i];
      }
      // Focus last pasted box or the next one
      int lastIndex = index + digits.length - 1;
      if (lastIndex >= 5) {
        _focusNodes[5].requestFocus();
      } else {
        _focusNodes[lastIndex + 1].requestFocus();
      }
    } else {
      // Handle single digit
      if (val.isNotEmpty && index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
      if (val.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    if (_otp.length == 6) _onVerify();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Verify your\nnumber 🔐',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                  fontFamily: 'Poppins',
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              Text.rich(
                TextSpan(
                  text: 'We sent a 6-digit code to ',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (val) => _onDigitEntered(i, val),
                )),
              ),
              const SizedBox(height: 32),

              // Resend
              Center(
                child: _canResend
                  ? TextButton(
                      onPressed: _startResendTimer,
                      child: const Text('Resend code'),
                    )
                  : Text(
                      'Resend code in ${_resendSeconds}s',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
              ),
              const Spacer(),

              // Verify button
              ElevatedButton(
                onPressed: _isLoading ? null : _onVerify,
                child: _isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Verify'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6, // Increased to allow paste to be captured
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.dark,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.greyLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}