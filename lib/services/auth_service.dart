// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.reload();
        user = _auth.currentUser;
        
        if (user == null) {
          throw Exception('Failed to create user. Please try again.');
        }

        try {
          await user.sendEmailVerification();
        } catch (e) {
          throw Exception('Failed to send verification email. Please check your Firebase Console settings: $e');
        }

        // Update display name if provided
        if (displayName != null) {
          await user.updateDisplayName(displayName);
          await user.reload();
          user = _auth.currentUser;
          if (user == null) {
            throw Exception('Failed to update user profile');
          }
        }

        // Create user profile in Firestore
        AppUser appUser = AppUser(
          uid: user.uid, // Safe because user is non-null
          email: user.email!, // Safe because email should exist
          displayName: displayName ?? user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          emailVerified: user.emailVerified,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(appUser.toFirestore());

        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An error occurred during sign up: $e');
    }
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Check if email is verified
        if (!user.emailVerified) {
          throw Exception('Please verify your email before logging in');
        }

        // Get user profile from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return AppUser.fromFirestore(
            userDoc.data() as Map<String, dynamic>,
            user.uid,
          );
        } else {
          // Create profile if it doesn't exist (fallback)
          AppUser appUser = AppUser(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName,
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            emailVerified: user.emailVerified,
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(appUser.toFirestore());

          return appUser;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An error occurred during sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }

  // Check if email is verified and update Firestore
  Future<bool> checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
        });
        return true;
      }
    }
    return false;
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw Exception('Email already verified');
      }
    } else {
      throw Exception('No user logged in');
    }
  }

  // Get current user profile from Firestore
  Future<AppUser?> getCurrentUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return AppUser.fromFirestore(
          userDoc.data() as Map<String, dynamic>,
          user.uid,
        );
      }
    }
    return null;
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    bool? notificationsEnabled,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic> updates = {};

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        updates['displayName'] = displayName;
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
        updates['photoUrl'] = photoUrl;
      }

      if (notificationsEnabled != null) {
        updates['notificationsEnabled'] = notificationsEnabled;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already registered.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}
