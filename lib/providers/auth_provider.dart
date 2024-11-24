import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_manager/services/auth_service.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());

// Provider for FirebaseAuth instance
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Provider for current user id
final getUserIdProvider = Provider<String?>((ref) {
  final firebaseAuth = FirebaseAuth.instance;
  final user = firebaseAuth.currentUser;
  return user?.uid;
});

/// Provider that listens auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Provider for authentication actions
final authServiceProvider = Provider<AuthService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthService(auth: auth, googleSignIn: googleSignIn);
});
