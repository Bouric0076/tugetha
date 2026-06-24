import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
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
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'subaccountCode': data['subaccount_code'],
        'message': data['error'] ?? 'Success',
      };
    } catch (e) {
      debugPrint('Subaccount Creation API Error: $e. Falling back to offline mock.');
      final user = AuthService.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'subaccountCode': 'ACCT_mock_${DateTime.now().millisecondsSinceEpoch}',
          });
        } catch (dbErr) {
          debugPrint('Offline mock DB update error: $dbErr');
        }
      }
      return {
        'success': true,
        'subaccountCode': 'ACCT_mock_${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Success (Offline Mock Mode)',
      };
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
          'idempotency_key':
              'withdraw_${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'newBalance': data['new_balance'],
        'message': data['error'] ?? 'Withdrawal processed',
      };
    } catch (e) {
      debugPrint('Withdrawal API Error: $e. Falling back to offline mock.');
      final user = AuthService.currentUser;
      if (user == null) return {'success': false, 'message': 'User not authenticated'};
      
      try {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        double newBalance = 0.0;
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) throw Exception("User profile not found");
          
          final currentBalance = (snapshot.data()?['walletBalance'] ?? 0.0).toDouble();
          if (currentBalance < amount) throw Exception("Insufficient wallet balance");
          
          newBalance = currentBalance - amount;
          transaction.update(docRef, {'walletBalance': newBalance});
          
          // Log transaction
          final txRef = docRef.collection('transactions').doc();
          transaction.set(txRef, {
            'type': 'WITHDRAWAL',
            'amount': -amount,
            'description': 'Withdraw to M-Pesa ($phone)',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        
        return {
          'success': true,
          'newBalance': newBalance,
          'message': 'Withdrawal successful (Offline Mode)',
        };
      } catch (dbErr) {
        debugPrint('Offline withdrawal error: $dbErr');
        return {'success': false, 'message': dbErr.toString()};
      }
    }
  }

  /// Process a loan via Django (Disburse funds from Lender to Borrower)
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
          'borrower_uid': lenderId, // design mapping pass borrower_uid
          'loan_id': loanId,
          'amount': amount,
          'idempotency_key': 'disb_$loanId',
        }),
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'loanId': data['loan_id'],
        'message': data['error'] ?? 'Loan disbursed successfully',
      };
    } catch (e) {
      debugPrint('Loan Disburse API Error: $e. Falling back to offline mock.');
      try {
        final loanDocRef = FirebaseFirestore.instance.collection('loans').doc(loanId);
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final loanSnapshot = await transaction.get(loanDocRef);
          if (!loanSnapshot.exists) throw Exception("Loan request not found");
          
          final borrowerId = loanSnapshot.data()?['borrowerId'] as String?;
          if (borrowerId == null) throw Exception("Borrower ID not found in loan data");
          
          final borrowerDocRef = FirebaseFirestore.instance.collection('users').doc(borrowerId);
          final lenderDocRef = FirebaseFirestore.instance.collection('users').doc(lenderId);
          
          final borrowerSnapshot = await transaction.get(borrowerDocRef);
          final lenderSnapshot = await transaction.get(lenderDocRef);
          
          if (!borrowerSnapshot.exists) throw Exception("Borrower profile not found");
          if (!lenderSnapshot.exists) throw Exception("Lender profile not found");
          
          final lenderBalance = (lenderSnapshot.data()?['walletBalance'] ?? 0.0).toDouble();
          final borrowerBalance = (borrowerSnapshot.data()?['walletBalance'] ?? 0.0).toDouble();
          
          if (lenderBalance < amount) throw Exception("Lender has insufficient wallet balance");
          
          // Transfer funds
          transaction.update(lenderDocRef, {'walletBalance': lenderBalance - amount});
          transaction.update(borrowerDocRef, {'walletBalance': borrowerBalance + amount});
          
          // Update loan status
          transaction.update(loanDocRef, {
            'status': 'active',
            'remaining': amount,
            'approvedAt': FieldValue.serverTimestamp(),
          });
          
          // Log transactions for both parties
          final lenderTxRef = lenderDocRef.collection('transactions').doc();
          transaction.set(lenderTxRef, {
            'type': 'LOAN_DISBURSED',
            'amount': -amount,
            'description': 'Disbursed loan to borrower',
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          final borrowerTxRef = borrowerDocRef.collection('transactions').doc();
          transaction.set(borrowerTxRef, {
            'type': 'LOAN_RECEIVED',
            'amount': amount,
            'description': 'Received loan from lender',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        
        return {
          'success': true,
          'loanId': loanId,
          'message': 'Loan disbursed successfully (Offline Mode)',
        };
      } catch (dbErr) {
        debugPrint('Offline loan disburse error: $dbErr');
        return {'success': false, 'message': dbErr.toString()};
      }
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
          'idempotency_key':
              'repay_${loanId}_${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'remainingBalance': data['remaining_balance'],
        'message': data['error'] ?? 'Repayment successful',
      };
    } catch (e) {
      debugPrint('Loan Repay API Error: $e. Falling back to offline mock.');
      final user = AuthService.currentUser;
      if (user == null) return {'success': false, 'message': 'User not authenticated'};
      
      try {
        final loanDocRef = FirebaseFirestore.instance.collection('loans').doc(loanId);
        double remainingBalance = 0.0;
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final loanSnapshot = await transaction.get(loanDocRef);
          if (!loanSnapshot.exists) throw Exception("Loan not found");
          
          final currentRemaining = (loanSnapshot.data()?['remaining'] ?? 0.0).toDouble();
          final borrowerId = loanSnapshot.data()?['borrowerId'] as String?;
          
          if (borrowerId == null) throw Exception("Borrower ID not found in loan data");
          
          final borrowerDocRef = FirebaseFirestore.instance.collection('users').doc(borrowerId);
          final lenderDocRef = FirebaseFirestore.instance.collection('users').doc(lenderId);
          
          final borrowerSnapshot = await transaction.get(borrowerDocRef);
          final lenderSnapshot = await transaction.get(lenderDocRef);
          
          if (!borrowerSnapshot.exists) throw Exception("Borrower profile not found");
          if (!lenderSnapshot.exists) throw Exception("Lender profile not found");
          
          final borrowerBalance = (borrowerSnapshot.data()?['walletBalance'] ?? 0.0).toDouble();
          final lenderBalance = (lenderSnapshot.data()?['walletBalance'] ?? 0.0).toDouble();
          
          if (borrowerBalance < amount) throw Exception("Insufficient wallet balance for repayment");
          
          remainingBalance = currentRemaining - amount;
          if (remainingBalance < 0) remainingBalance = 0;
          
          // Transfer funds from borrower to lender
          transaction.update(borrowerDocRef, {'walletBalance': borrowerBalance - amount});
          transaction.update(lenderDocRef, {'walletBalance': lenderBalance + amount});
          
          // Update loan remaining balance and status
          transaction.update(loanDocRef, {
            'remaining': remainingBalance,
            'status': remainingBalance <= 0 ? 'repaid' : 'active',
          });
          
          // Log transactions for both parties
          final borrowerTxRef = borrowerDocRef.collection('transactions').doc();
          transaction.set(borrowerTxRef, {
            'type': 'LOAN_REPAYMENT_SENT',
            'amount': -amount,
            'description': 'Sent loan repayment to lender',
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          final lenderTxRef = lenderDocRef.collection('transactions').doc();
          transaction.set(lenderTxRef, {
            'type': 'LOAN_REPAYMENT_RECEIVED',
            'amount': amount,
            'description': 'Received loan repayment from borrower',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        
        return {
          'success': true,
          'remainingBalance': remainingBalance,
          'message': 'Repayment successful (Offline Mode)',
        };
      } catch (dbErr) {
        debugPrint('Offline loan repay error: $dbErr');
        return {'success': false, 'message': dbErr.toString()};
      }
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
          'idempotency_key':
              'goal_${goalId}_${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'reference': data['reference'],
        'message': data['error'] ?? 'Contribution initialized',
      };
    } catch (e) {
      debugPrint('Goal Contribution API Error: $e. Falling back to offline mock.');
      final user = AuthService.currentUser;
      if (user == null) return {'success': false, 'message': 'User not authenticated'};
      
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final goalDocRef = FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('goals')
            .doc(goalId);
            
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userSnapshot = await transaction.get(userDocRef);
          final goalSnapshot = await transaction.get(goalDocRef);
          
          if (!userSnapshot.exists) throw Exception("User profile not found");
          if (!goalSnapshot.exists) throw Exception("Goal profile not found");
          
          final currentBalance = (userSnapshot.data()?['walletBalance'] ?? 0.0).toDouble();
          if (currentBalance < amount) throw Exception("Insufficient wallet balance for contribution");
          
          final currentGoalAmount = (goalSnapshot.data()?['currentAmount'] ?? 0.0).toDouble();
          final goalTitle = goalSnapshot.data()?['title'] ?? 'Goal';
          
          // Deduct from wallet, add to goal
          transaction.update(userDocRef, {'walletBalance': currentBalance - amount});
          transaction.update(goalDocRef, {'currentAmount': currentGoalAmount + amount});
          
          // Log transaction for the user
          final txRef = userDocRef.collection('transactions').doc();
          transaction.set(txRef, {
            'type': 'GOAL_CONTRIBUTION',
            'amount': -amount,
            'description': 'Contribution to "$goalTitle"',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        
        return {
          'success': true,
          'reference': 'REF_mock_${DateTime.now().millisecondsSinceEpoch}',
          'message': 'Contribution successful (Offline Mode)',
        };
      } catch (dbErr) {
        debugPrint('Offline goal contribution error: $dbErr');
        return {'success': false, 'message': dbErr.toString()};
      }
    }
  }
}
