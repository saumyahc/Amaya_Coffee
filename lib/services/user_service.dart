import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  UserService(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference get _col => _firestore.collection('users');

  Future<void> createUserProfile({
    required String uid,
    required String username,
  }) async {
    await _col.doc(uid).set({
      'username': username,
      'orders': <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserProfile?> fetchUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Stream<UserProfile?> userStream(String uid) {
    return _col.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromFirestore(snap);
    });
  }

  Future<void> appendOrder(String uid, Map<String, dynamic> order) async {
    await _col.doc(uid).update({
      'orders': FieldValue.arrayUnion([order]),
    });
  }
}
