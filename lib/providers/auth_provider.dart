import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// Provider for AuthService (singleton)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for auth state changes stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider for current user profile from Firestore
final currentUserProfileProvider = FutureProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUserProfile();
});

// Provider for authentication state (whether user is logged in)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value != null;
});

// Provider for checking if email is verified
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  return user?.emailVerified ?? false;
});

// Provider for current user's UID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.uid;
});

// Provider for auth loading state (useful for showing loading indicators)
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for auth error messages
final authErrorProvider = StateProvider<String?>((ref) => null);

// Provider for managing sign up form state
final signUpFormProvider = StateProvider<SignUpFormState>((ref) {
  return SignUpFormState(
    email: '',
    password: '',
    confirmPassword: '',
    displayName: '',
  );
});

// Provider for managing sign in form state
final signInFormProvider = StateProvider<SignInFormState>((ref) {
  return SignInFormState(email: '', password: '');
});

// Form state classes
class SignUpFormState {
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;
  final bool isLoading;
  final String? error;

  SignUpFormState({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.displayName,
    this.isLoading = false,
    this.error,
  });

  SignUpFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? displayName,
    bool? isLoading,
    String? error,
  }) {
    return SignUpFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      displayName: displayName ?? this.displayName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SignInFormState {
  final String email;
  final String password;
  final bool isLoading;
  final String? error;

  SignInFormState({
    required this.email,
    required this.password,
    this.isLoading = false,
    this.error,
  });

  SignInFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? error,
  }) {
    return SignInFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider for sign up function
final signUpProvider = FutureProvider.autoDispose
    .family<AppUser?, SignUpCredentials>((ref, credentials) async {
      final authService = ref.watch(authServiceProvider);
      final loadingController = ref.watch(authLoadingProvider.notifier);
      final errorController = ref.watch(authErrorProvider.notifier);

      try {
        loadingController.state = true;
        errorController.state = null;

        final user = await authService.signUpWithEmail(
          email: credentials.email,
          password: credentials.password,
          displayName: credentials.displayName,
        );

        return user;
      } catch (e) {
        errorController.state = e.toString();
        return null;
      } finally {
        loadingController.state = false;
      }
    });

// Provider for sign in function
final signInProvider = FutureProvider.autoDispose
    .family<AppUser?, SignInCredentials>((ref, credentials) async {
      final authService = ref.watch(authServiceProvider);
      final loadingController = ref.watch(authLoadingProvider.notifier);
      final errorController = ref.watch(authErrorProvider.notifier);

      try {
        loadingController.state = true;
        errorController.state = null;

        final user = await authService.signInWithEmail(
          email: credentials.email,
          password: credentials.password,
        );

        return user;
      } catch (e) {
        errorController.state = e.toString();
        return null;
      } finally {
        loadingController.state = false;
      }
    });

// Provider for sign out function
final signOutProvider = Provider<Future<void> Function()>((ref) {
  final authService = ref.watch(authServiceProvider);
  return () async {
    final loadingController = ref.watch(authLoadingProvider.notifier);
    try {
      loadingController.state = true;
      await authService.signOut();
    } finally {
      loadingController.state = false;
    }
  };
});

// Provider for resend verification email
final resendVerificationProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  final authService = ref.watch(authServiceProvider);
  await authService.resendVerificationEmail();
});

// Provider for checking email verification
final checkEmailVerificationProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.checkEmailVerification();
});

// Credentials classes
class SignUpCredentials {
  final String email;
  final String password;
  final String displayName;

  SignUpCredentials({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

class SignInCredentials {
  final String email;
  final String password;

  SignInCredentials({required this.email, required this.password});
}
