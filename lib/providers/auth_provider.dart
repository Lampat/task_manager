import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

/// Controller to handle authentication actions
class AuthService {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  AuthService({required this.auth, required this.googleSignIn});

  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> register(String email, String password) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // Sign in aborted by user
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with Google credentials
    await auth.signInWithCredential(credential);
  }
}
