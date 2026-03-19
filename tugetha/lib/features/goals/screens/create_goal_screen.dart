import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../core/providers/app_providers.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  final String? groupId;
  const CreateGoalScreen({super.key, this.groupId});

  @override
  ConsumerState<CreateGoalScreen> createState() =>
      _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = '✈️ Trip';
  String? _selectedGroupId;
  DateTime? _deadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.groupId;
  }

  final _categories = [
    '✈️ Trip', '🎉 Event', '🏥 Emergency',
    '💼 Business', '🎓 Education', '🛒 Shopping',
    '🏠 Home', '🎯 Other',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().add(const Duration(days: 30)),
      firstDate:
          DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now()
          .add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _onCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a group for this goal',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please pick a deadline',
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

      await FirestoreService.createGoal(
        groupId: _selectedGroupId!,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        targetAmount: double.parse(
            _amountController.text.trim()),
        deadline: _deadline!,
        creatorId: user.uid,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Goal "${_titleController.text}" created!',
              style:
                  const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create goal. Try again.',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Goal'),
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
                if (widget.groupId == null) ...[
                  const Text(
                    'Select Group',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ref.watch(groupsProvider).when(
                        data: (snapshot) {
                          if (snapshot == null ||
                              snapshot.docs.isEmpty) {
                            return const Text(
                                'No groups found. Create a group first.');
                          }
                          return DropdownButtonFormField<
                              String>(
                            value: _selectedGroupId,
                            hint: const Text('Pick a group'),
                            items: snapshot.docs.map((doc) {
                              final data = doc.data()
                                  as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(
                                    '${data['emoji'] ?? '👥'} ${data['name']}'),
                              );
                            }).toList(),
                            onChanged: (val) => setState(
                                () => _selectedGroupId = val),
                            validator: (val) => val == null
                                ? 'Please select a group'
                                : null,
                          );
                        },
                        loading: () =>
                            const CircularProgressIndicator(),
                        error: (e, _) =>
                            Text('Error loading groups: $e'),
                      ),
                  const SizedBox(height: 20),
                ],

                // Goal title
                const Text(
                  'Goal Title',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textCapitalization:
                      TextCapitalization.words,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Diani Trip',
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                      color: AppColors.grey,
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty
                          ? 'Please enter a goal title'
                          : null,
                ),
                const SizedBox(height: 20),

                // Target amount
                const Text(
                  'Target Amount',
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
                    fontSize: 20,
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
                          fontSize: 16,
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
                      return 'Please enter a target amount';
                    }
                    if ((int.tryParse(val) ?? 0) < 100) {
                      return 'Minimum goal is KES 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category
                const Text(
                  'Category',
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
                  children: _categories.map((cat) {
                    final isSelected =
                        _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(
                          () => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLighter
                              : AppColors.white,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.greyLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Deadline
                const Text(
                  'Deadline',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.greyLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _deadline == null
                              ? 'Pick a deadline'
                              : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: _deadline == null
                                ? AppColors.greyLight
                                : AppColors.dark,
                            fontWeight: _deadline == null
                                ? FontWeight.w400
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onCreate,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Goal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}