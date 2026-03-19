import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class WalletService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  /// Create a Paystack Subaccount for the user via Django
  static Future<Map<String, dynamic>> createSubaccount({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      final token = await AuthService.idToken;
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/subaccount/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'subaccountCode': data['subaccount_code'],
        'message': data['error'] ?? 'Success',
      };
    } catch (e) {
      debugPrint('Subaccount Creation Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Securely withdraw funds via Django
  static Future<Map<String, dynamic>> withdraw({
    required double amount,
    required String phone,
  }) async {
    try {
      final token = await AuthService.idToken;
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/withdraw/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'phone': phone,
          'idempotency_key': 'withdraw_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'newBalance': data['new_balance'],
        'message': data['error'] ?? 'Withdrawal processed',
      };
    } catch (e) {
      debugPrint('Withdrawal Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Process a loan via Django
  static Future<Map<String, dynamic>> processLoan({
    required String lenderId,
    required String groupId,
    required double amount,
    required double interestRate,
    required int durationMonths,
    required String loanId,
  }) async {
    try {
      final token = await AuthService.idToken;
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('$_baseUrl/loans/disburse/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'borrower_uid': lenderId, // Wait, the design says borrower_uid is passed by lender
          'loan_id': loanId,
          'amount': amount,
          'idempotency_key': 'disb_$loanId',
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'loanId': data['loan_id'],
        'message': data['error'] ?? 'Loan disbursed successfully',
      };
    } catch (e) {
      debugPrint('Loan Processing Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Repay a loan via Django
  static Future<Map<String, dynamic>> repayLoan({
    required String loanId,
    required double amount,
    required String lenderId,
  }) async {
    try {
      final token = await AuthService.idToken;
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('$_baseUrl/loans/repay/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'loan_id': loanId,
          'lender_uid': lenderId,
          'amount': amount,
          'idempotency_key': 'repay_${loanId}_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'remainingBalance': data['remaining_balance'],
        'message': data['error'] ?? 'Repayment successful',
      };
    } catch (e) {
      debugPrint('Repayment Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Contribute to a goal via Django (P2P Transfer)
  static Future<Map<String, dynamic>> contributeToGoal({
    required String groupId,
    required String goalId,
    required double amount,
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
          'amount': amount,
          'type': 'goal_contribution',
          'metadata': {
            'group_id': groupId,
            'goal_id': goalId,
          },
          'idempotency_key': 'goal_${goalId}_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'reference': data['reference'],
        'message': data['error'] ?? 'Contribution initialized',
      };
    } catch (e) {
      debugPrint('Goal Contribution Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
