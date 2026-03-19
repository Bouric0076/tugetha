import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/wallet_service.dart';

class WithdrawScreen extends StatefulWidget {
  final double balance;
  const WithdrawScreen({super.key, required this.balance});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _useRegistered = true;

  static const double _withdrawalFee = 10.0;

  void _onWithdraw() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.parse(_amountController.text.trim());
    final total = amount + _withdrawalFee;

    if (total > widget.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance to cover withdrawal and fee.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final targetPhone = _useRegistered ? user.phoneNumber : _phoneController.text.trim();
      
      if (targetPhone == null || targetPhone.isEmpty) {
        throw Exception('Target phone number not provided.');
      }

      // 1. Execute withdrawal via secure Firebase Function
      // This function handles balance deduction and transaction logging atomically
      final result = await WalletService.withdraw(
        amount: total,
        phone: targetPhone,
      );

      if (result['success'] == true) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccess(amount);
        }
      } else {
        throw Exception(result['message'] ?? 'Withdrawal failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Withdrawal failed: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccess(double amount) {
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
              'Withdrawal Initiated!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'KES ${amount.toStringAsFixed(0)} is being sent to your M-Pesa.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A fee of KES 10 has been charged.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warning,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Wallet'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdraw'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryLight,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KES ${widget.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Amount
                const Text(
                  'Amount to Withdraw',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontSize: 28,
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
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount =
                        double.tryParse(val) ?? 0;
                    if (amount < 100) {
                      return 'Minimum withdrawal is KES 100';
                    }
                    if (amount + _withdrawalFee >
                        widget.balance) {
                      return 'Insufficient balance (includes KES 10 fee)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Withdrawal fee: KES 10 per transaction',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),

                // Send to
                const Text(
                  'Send To',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PhoneToggle(
                      label: 'My M-Pesa',
                      selected: _useRegistered,
                      onTap: () => setState(
                          () => _useRegistered = true),
                    ),
                    const SizedBox(width: 10),
                    _PhoneToggle(
                      label: 'Other Number',
                      selected: !_useRegistered,
                      onTap: () => setState(
                          () => _useRegistered = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_useRegistered)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.greyLighter),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          color: AppColors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AuthService.currentUser
                                  ?.phoneNumber ??
                              '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Registered',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      hintText: '07XX XXX XXX',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: AppColors.grey,
                      ),
                    ),
                    validator: (val) {
                      if (!_useRegistered) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (val.length < 10) {
                          return 'Enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onWithdraw,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Withdraw Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PhoneToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.greyLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color:
                selected ? Colors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }
}