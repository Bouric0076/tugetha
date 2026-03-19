import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

// Current user provider
final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = AuthService.currentUser;
  if (user == null) return null;
  return FirestoreService.getUser(user.uid);
});

// User stream provider
final userStreamProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final user = AuthService.currentUser;
  if (user == null) return const Stream.empty();
  return FirestoreService.userStream(user.uid);
});

// Wallet balance provider
final walletBalanceProvider = Provider<double>((ref) {
  final userSnapshot = ref.watch(userStreamProvider);
  return userSnapshot.when(
    data: (doc) {
      if (doc == null || !doc.exists) return 0.0;
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['walletBalance'] ?? 0.0).toDouble();
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Transactions provider
final transactionsProvider = StreamProvider<QuerySnapshot?>((ref) {
  final user = AuthService.currentUser;
  if (user == null) return Stream.value(null);
  return FirestoreService.transactionsStream(user.uid);
});

// Groups provider
final groupsProvider = StreamProvider<QuerySnapshot?>((ref) {
  final user = AuthService.currentUser;
  if (user == null) return Stream.value(null);
  return FirestoreService.userGroupsStream(user.uid);
});

// Loans provider
final borrowingLoansProvider = StreamProvider<QuerySnapshot?>((ref) {
  final user = AuthService.currentUser;
  if (user == null) return Stream.value(null);
  return FirestoreService.userLoansStream(user.uid, 'borrower');
});

final lendingLoansProvider = StreamProvider<QuerySnapshot?>((ref) {
  final user = AuthService.currentUser;
  if (user == null) return Stream.value(null);
  return FirestoreService.userLoansStream(user.uid, 'lender');
});