import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../services/wallet_service.dart';
import '../../home/screens/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mpesaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _onFinish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirestoreService.createUser(
        uid: user.uid,
        phone: user.phoneNumber ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mpesaNumber: _mpesaController.text.trim(),
      );

      // 3. Create Paystack Subaccount (Facilitator model) via Django
      final subaccountResult = await WalletService.createSubaccount(
        name: _nameController.text.trim(),
        phone: _mpesaController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (subaccountResult['success'] != true) {
        throw Exception(subaccountResult['message'] ?? 'Failed to setup financial account');
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error saving profile. Please try again.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mpesaController.dispose();
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

                const Text(
                  'Set up your\nprofile ✨',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us a bit about yourself.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 40),

                // Profile photo picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primaryLighter,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Tap to add photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Full name
                const _FieldLabel('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. John Kamau',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.grey,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (val.trim().split(' ').length < 2) {
                      return 'Please enter your first and last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email address
                const _FieldLabel('Email Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. john@example.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.grey,
                    ),
                    helperText: 'Required for processing payments via Paystack',
                    helperStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // M-Pesa number
                const _FieldLabel('M-Pesa Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mpesaController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark,
                  ),
                  decoration: const InputDecoration(
                    hintText: '07XX XXX XXX',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.grey,
                    ),
                    helperText: 'Used for wallet top-ups and withdrawals',
                    helperStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your M-Pesa number';
                    }
                    if (val.trim().length < 10) {
                      return 'Enter a valid M-Pesa number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),

                // Finish button
                ElevatedButton(
                  onPressed: _isLoading ? null : _onFinish,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Finish Setup'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        fontFamily: 'Poppins',
      ),
    );
  }
}