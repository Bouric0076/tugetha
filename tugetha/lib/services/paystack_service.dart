import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PaystackService {
  // Django Backend Base URL
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  /// Initialize a Paystack payment (M-Pesa STK Push) via Django
  static Future<Map<String, dynamic>?> initializePayment({
    required String phone,
    required double amount,
    String? receiverUid,
  }) async {
    try {
      final token = await AuthService.idToken;
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/initialize/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phone': phone,
          'amount': amount,
          'type': receiverUid != null ? 'p2p_transfer' : 'top_up',
          'receiver_uid': receiverUid,
          'idempotency_key': DateTime.now().millisecondsSinceEpoch.toString(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'reference': data['reference']};
      }
      
      throw Exception(data['error'] ?? 'Failed to initialize payment');
    } catch (e) {
      debugPrint('Paystack Initialization Error: $e');
      rethrow;
    }
  }

  /// Verify a Paystack payment via Django
  static Future<String> verifyPayment(String reference) async {
    try {
      final token = await AuthService.idToken;
      if (token == null) return 'unauthenticated';

      final response = await http.get(
        Uri.parse('$_baseUrl/payments/verify/$reference/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['status'] ?? 'pending';
      }
      return 'error';
    } catch (e) {
      debugPrint('Paystack Verification Error: $e');
      return 'error';
    }
  }

  /// Show a modern in-app loading dialog while waiting for STK Push / Verification
  static Future<void> waitForStkPush({
    required BuildContext context,
    required String reference,
    required Function(bool success) onCompleted,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Processing Payment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please check your phone for the M-Pesa STK push and enter your PIN.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );

    // Poll for verification
    bool isVerified = false;
    int attempts = 0;
    const maxAttempts = 15; // 15 * 4 seconds = 60 seconds max wait

    while (!isVerified && attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 4));
      final status = await verifyPayment(reference);
      
      if (status == 'success' || status == 'already_processed') {
        isVerified = true;
        if (context.mounted) Navigator.pop(context);
        onCompleted(true);
        return;
      }
      attempts++;
    }

    if (context.mounted) Navigator.pop(context);
    onCompleted(false);
  }
}
