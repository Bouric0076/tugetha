import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import 'profile_setup_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _hasError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _keys = [
    '1','2','3','4','5','6','7','8','9','','0','⌫'
  ];

  void _onKeyTap(String key) {
    if (_isLoading) return;
    
    setState(() {
      _hasError = false;
      _errorMessage = '';

      if (key == '⌫') {
        if (!_isConfirming && _pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        } else if (_isConfirming && _confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
        return;
      }

      if (key.isEmpty) return;

      if (!_isConfirming) {
        if (_pin.length < 6) _pin += key;
        if (_pin.length == 6) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _isConfirming = true);
          });
        }
      } else {
        if (_confirmPin.length < 6) _confirmPin += key;
        if (_confirmPin.length == 6) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _verifyPins();
          });
        }
      }
    });
  }

  void _verifyPins() async {
    if (_pin == _confirmPin) {
      setState(() => _isLoading = true);
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_pin', _pin);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Error saving PIN. Please try again.';
          });
        }
      }
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'PINs do not match. Try again.';
        _confirmPin = '';
        _isConfirming = false;
        _pin = '';
      });
    }
  }

  Widget _buildDots(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: filled ? 18 : 16,
          height: filled ? 18 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? (_hasError ? AppColors.error : AppColors.primary)
                : AppColors.greyLight,
            border: filled
                ? null
                : Border.all(color: AppColors.greyLight),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _isConfirming ? 'Confirm your PIN' : 'Create your PIN',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _isConfirming
                        ? 'Enter your PIN again to confirm'
                        : 'Choose a 6-digit PIN to secure your account',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // PIN dots
                  _buildDots(currentPin),
                  const SizedBox(height: 16),

                  // Error message
                  AnimatedOpacity(
                    opacity: _hasError ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Keypad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _keys.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, i) {
                        final key = _keys[i];
                        if (key.isEmpty) return const SizedBox();

                        final isBackspace = key == '⌫';
                        return InkWell(
                          onTap: () => _onKeyTap(key),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isBackspace
                                  ? Colors.transparent
                                  : AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: isBackspace
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                            ),
                            child: Center(
                              child: Text(
                                key,
                                style: TextStyle(
                                  fontSize: isBackspace ? 22 : 24,
                                  fontWeight: FontWeight.w600,
                                  color: isBackspace
                                      ? AppColors.grey
                                      : AppColors.dark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}