import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ──
  static Future<void> createUser({
    required String uid,
    required String phone,
    required String name,
    required String email,
    String? mpesaNumber,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'phone': phone,
      'name': name,
      'email': email,
      'mpesaNumber': mpesaNumber ?? phone,
      'walletBalance': 0.0,
      'trustScore': 50,
      'kycStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> userExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> updateUser(
      String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  static Stream<DocumentSnapshot> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Search users by phone number
  static Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final snapshot = await _db
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return {
      'uid': snapshot.docs.first.id,
      ...snapshot.docs.first.data(),
    };
  }

  // Get all users except current (for friend search)
  static Future<List<Map<String, dynamic>>> searchUsers(
      String query, String currentUid) async {
    final snapshot = await _db
        .collection('users')
        .where('phone', isGreaterThanOrEqualTo: query)
        .where('phone', isLessThan: '${query}z')
        .limit(10)
        .get();

    return snapshot.docs
        .where((doc) => doc.id != currentUid)
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();
  }

  static Stream<QuerySnapshot> transactionsStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> userLoansStream(String uid, String role) {
    return _db
        .collection('loans')
        .where(role == 'borrower' ? 'borrowerId' : 'lenderId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ── Groups ──
  static Future<String> createGroup({
    required String name,
    required String emoji,
    required String creatorId,
  }) async {
    final doc = await _db.collection('groups').add({
      'name': name,
      'emoji': emoji,
      'creatorId': creatorId,
      'members': [creatorId],
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Add group to user's groups list
    await _db.collection('users').doc(creatorId).update({
      'groups': FieldValue.arrayUnion([doc.id]),
    });
    return doc.id;
  }

  static Stream<QuerySnapshot> userGroupsStream(String uid) {
    return _db
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  // ── Goals ──
  static Future<String> createGoal({
    required String groupId,
    required String title,
    required String category,
    required double targetAmount,
    required DateTime deadline,
    required String creatorId,
  }) async {
    final doc = await _db
        .collection('groups')
        .doc(groupId)
        .collection('goals')
        .add({
      'title': title,
      'category': category,
      'targetAmount': targetAmount,
      'currentAmount': 0.0,
      'deadline': Timestamp.fromDate(deadline),
      'creatorId': creatorId,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Stream<QuerySnapshot> goalsStream(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('goals')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  // ── Loans ──
  static Future<String> createLoan({
    required String borrowerId,
    required String lenderId,
    required double amount,
    required String purpose,
    required String repaymentPeriod,
    double interestRate = 5.0,
  }) async {
    final doc = await _db.collection('loans').add({
      'borrowerId': borrowerId,
      'lenderId': lenderId,
      'amount': amount,
      'remaining': amount,
      'purpose': purpose,
      'repaymentPeriod': repaymentPeriod,
      'interestRate': interestRate,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
