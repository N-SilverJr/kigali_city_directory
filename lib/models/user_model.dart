import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final bool emailVerified;
  final bool notificationsEnabled;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.emailVerified,
    this.notificationsEnabled = true, // Default value
  });

  // Convert from Firestore document to AppUser object
  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      emailVerified: data['emailVerified'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  // Convert AppUser object to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'emailVerified': emailVerified,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  // Copy with method for updating specific fields
  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    bool? notificationsEnabled,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
