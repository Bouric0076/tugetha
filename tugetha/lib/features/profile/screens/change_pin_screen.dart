import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

enum _PinStep { current, newPin, confirm }

class _ChangePinScreenState extends State<ChangePinScreen> {
  _PinStep _step = _PinStep.current;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  bool _hasError = false;
  String _errorMessage = '';

  // Hardcoded for now — will come from secure storage after Firebase
  static const String _savedPin = '123456';

  final List<String> _keys = [
    '1','2','3','4','5','6','7','8','9','','0','⌫'
  ];

  String get _activePin {
    switch (_step) {
      case _PinStep.current:
        return _currentPin;
      case _PinStep.newPin:
        return _newPin;
      case _PinStep.confirm:
        return _confirmPin;
    }
  }

  String get _title {
    switch (_step) {
      case _PinStep.current:
        return 'Enter current PIN';
      case _PinStep.newPin:
        return 'Enter new PIN';
      case _PinStep.confirm:
        return 'Confirm new PIN';
    }
  }

  String get _subtitle {
    switch (_step) {
      case _PinStep.current:
        return 'Enter your existing 6-digit PIN';
      case _PinStep.newPin:
        return 'Choose a new 6-digit PIN';
      case _PinStep.confirm:
        return 'Enter your new PIN again';
    }
  }

  void _onKeyTap(String key) {
    setState(() {
      _hasError = false;
      _errorMessage = '';

      if (key == '⌫') {
        switch (_step) {
          case _PinStep.current:
            if (_currentPin.isNotEmpty) {
              _currentPin =
                  _currentPin.substring(0, _currentPin.length - 1);
            }
            break;
          case _PinStep.newPin:
            if (_newPin.isNotEmpty) {
              _newPin = _newPin.substring(0, _newPin.length - 1);
            }
            break;
          case _PinStep.confirm:
            if (_confirmPin.isNotEmpty) {
              _confirmPin =
                  _confirmPin.substring(0, _confirmPin.length - 1);
            }
            break;
        }
        return;
      }

      if (key.isEmpty) return;

      switch (_step) {
        case _PinStep.current:
          if (_currentPin.length < 6) _currentPin += key;
          if (_currentPin.length == 6) {
            Future.delayed(const Duration(milliseconds: 300), _validateCurrent);
          }
          break;
        case _PinStep.newPin:
          if (_newPin.length < 6) _newPin += key;
          if (_newPin.length == 6) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() => _step = _PinStep.confirm);
            });
          }
          break;
        case _PinStep.confirm:
          if (_confirmPin.length < 6) _confirmPin += key;
          if (_confirmPin.length == 6) {
            Future.delayed(
                const Duration(milliseconds: 300), _validateNew);
          }
          break;
      }
    });
  }

  void _validateCurrent() {
    if (_currentPin == _savedPin) {
      setState(() => _step = _PinStep.newPin);
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Incorrect PIN. Try again.';
        _currentPin = '';
      });
    }
  }

  void _validateNew() {
    if (_newPin == _confirmPin) {
      _showSuccess();
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'PINs do not match. Try again.';
        _confirmPin = '';
        _newPin = '';
        _step = _PinStep.newPin;
      });
    }
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.accentLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PIN Changed! 🔐',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your transaction PIN has been\nupdated successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Profile'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    final pin = _activePin;
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

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _PinStep.values.map((step) {
        final isActive = step == _step;
        final isPast = step.index < _step.index;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isPast || isActive
                    ? AppColors.primary
                    : AppColors.greyLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (step != _PinStep.confirm)
              const SizedBox(width: 6),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Change PIN'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: 32),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _hasError
                    ? const Color(0xFFFCEBEB)
                    : AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _hasError
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline_rounded,
                color:
                    _hasError ? AppColors.error : AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 36),

            // Dots
            _buildDots(),
            const SizedBox(height: 16),

            // Error
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
                                  color:
                                      Colors.black.withOpacity(0.05),
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
    );
  }
}