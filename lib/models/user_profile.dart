import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id; // Firebase Auth UID
  final String username;
  final List<Map<String, dynamic>> orders; // Each order detail map
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.orders,
    this.createdAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      id: doc.id,
      username: data['username'] ?? '',
      orders: (data['orders'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'username': username,
        'orders': orders,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };
}
