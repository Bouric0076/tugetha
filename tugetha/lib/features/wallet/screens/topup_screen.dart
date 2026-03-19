import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/paystack_service.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _quickAmounts = [100, 500, 1000, 2000, 5000];

  void _onTopUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final amount = double.parse(_amountController.text.trim());
      final phone = user.phoneNumber;

      if (phone == null || phone.isEmpty) {
        throw Exception('Phone number not found');
      }

      // 1. Initialize payment via Firebase Function (Paystack Charge API)
      final data = await PaystackService.initializePayment(
        phone: phone,
        amount: amount,
      );

      if (data == null || data['reference'] == null) {
        throw Exception('Failed to initialize payment');
      }

      final reference = data['reference'];

      if (mounted) {
        setState(() => _isLoading = false);
        
        // 2. Show in-app dialog and wait for STK Push completion
        await PaystackService.waitForStkPush(
          context: context,
          reference: reference,
          onCompleted: (success) {
            if (success) {
              _showSuccess(amount);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment verification failed or timed out.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Top up failed: ${e.toString()}',
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
              'Top Up Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'KES ${amount.toStringAsFixed(0)} has been\nadded to your wallet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
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
                // Amount field
                const Text(
                  'Enter Amount',
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
                  autofocus: true,
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
                    final amount = int.tryParse(val) ?? 0;
                    if (amount < 50) {
                      return 'Minimum top up is KES 50';
                    }
                    if (amount > 150000) {
                      return 'Maximum top up is KES 150,000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Quick amounts
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _quickAmounts.map((amount) {
                    return GestureDetector(
                      onTap: () => setState(() =>
                          _amountController.text =
                              amount.toString()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.greyLight),
                        ),
                        child: Text(
                          'KES $amount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Payment method
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'M',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4CAF50),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'M-Pesa',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              'STK push to your number',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note: Flutterwave STK Push integration coming soon. For now wallet is updated directly.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onTopUp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Top Up Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}