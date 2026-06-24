import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get ID Token for backend auth
  static Future<String?> get idToken async =>
      await _auth.currentUser?.getIdToken();

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send OTP
  static Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    Function(String verificationId)? onAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('Firebase phone auth: automatic verification completed.');
          onAutoVerified(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint(
            'Firebase phone auth failed: ${e.code} ${e.message ?? ''}',
          );
          onError(_phoneAuthErrorMessage(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('Firebase phone auth: code sent.');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Firebase phone auth: auto retrieval timed out.');
          onAutoRetrievalTimeout?.call(verificationId);
        },
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      onError(_phoneAuthErrorMessage(e));
    } catch (_) {
      onError('Unable to start phone verification. Please try again.');
    }
  }

  static String _phoneAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Enter a valid Kenyan phone number.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'app-not-authorized':
      case 'missing-client-identifier':
      case 'captcha-check-failed':
        return 'This app is not fully authorized for phone login yet. Please contact support.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet and try again.';
      default:
        return error.message ?? 'Verification failed. Please try again.';
    }
  }

  // Verify OTP
  static Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String otp,
    required Function(String error) onError,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'Invalid OTP');
      return null;
    }
  }
}
