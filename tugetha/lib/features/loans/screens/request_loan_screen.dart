import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/wallet_service.dart';

class RequestLoanScreen extends StatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  State<RequestLoanScreen> createState() =>
      _RequestLoanScreenState();
}

class _RequestLoanScreenState
    extends State<RequestLoanScreen> {
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedPeriod = '1 Month';
  Map<String, dynamic>? _selectedFriend;
  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  final _periods = [
    '1 Week', '2 Weeks', '1 Month',
    '2 Months', '3 Months',
  ];

  void _searchFriend(String phone) async {
    if (phone.length < 5) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final user = AuthService.currentUser;
      final results = await FirestoreService.searchUsers(
        phone,
        user?.uid ?? '',
      );
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFriend == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a friend to request from',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      // 1. Create a pending loan request in Firestore
      final loanId = await FirestoreService.createLoan(
        borrowerId: user.uid,
        lenderId: _selectedFriend!['uid'],
        amount: double.parse(_amountController.text.trim()),
        purpose: _purposeController.text.trim(),
        repaymentPeriod: _selectedPeriod,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showConfirmation();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send request: ${e.toString().replaceAll('Exception:', '').trim()}',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Request Sent! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedFriend!['name']} will be notified to review your request.',
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
              child: const Text('Back to Loans'),
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
    _purposeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request a Loan'),
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
                // Wallet balance hint
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Loan will be added to your wallet balance after approval',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Amount
                const Text(
                  'How much do you need?',
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
                      padding: EdgeInsets.only(
                          left: 16, right: 8),
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
                    if ((int.tryParse(val) ?? 0) < 100) {
                      return 'Minimum loan is KES 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Purpose
                const Text(
                  'What is it for?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _purposeController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.dark,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. Rent top-up, Emergency...',
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.grey,
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty
                          ? 'Please describe the purpose'
                          : null,
                ),
                const SizedBox(height: 24),

                // Repayment period
                const Text(
                  'Repayment period',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _periods.map((p) {
                    final isSelected = _selectedPeriod == p;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPeriod = p),
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.greyLight,
                          ),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Search friend
                const Text(
                  'Request from',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: _searchFriend,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.dark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by phone number',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.grey,
                    ),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),

                // Search results
                if (_searchResults.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.greyLighter),
                    ),
                    child: Column(
                      children: _searchResults.map((friend) {
                        final isSelected =
                            _selectedFriend?['uid'] ==
                                friend['uid'];
                        final name =
                            friend['name'] ?? 'User';
                        final initials = name
                            .split(' ')
                            .map((e) =>
                                e.isNotEmpty ? e[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase();

                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedFriend = friend),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLighter
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : AppColors
                                          .primaryLighter,
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primary,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: AppColors.dark,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Text(
                                        friend['phone'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons
                                          .check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.greyLight,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                if (_searchResults.isEmpty &&
                    _phoneController.text.length > 4 &&
                    !_isSearching)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.greyLighter),
                    ),
                    child: const Center(
                      child: Text(
                        'No Tugetha users found with that number.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),

                if (_selectedFriend != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentLighter,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Requesting from ${_selectedFriend!['name']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Fee notice
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A 2.5% facilitation fee will be deducted from the loan amount on disbursement.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontFamily: 'Poppins',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send Request'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}