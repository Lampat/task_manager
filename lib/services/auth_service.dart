import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_manager/globals.dart';

class AuthService {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  AuthService({required this.auth, required this.googleSignIn});

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState?.showSnackBar(
          globalSnackBar("Some error occurred, please try again later."));
      // Add analytics to see the error
      if (kDebugMode) {
        print(e.code);
        print(e.message);
      }
    }
  }

  // User sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState?.showSnackBar(
          globalSnackBar("Some error occurred, please try again later."));
      // Add analytics to see the error
      if (kDebugMode) {
        print(e.code);
        print(e.message);
      }
    }
  }

  // Register a new user to the app with email and password
  Future<void> register(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState?.showSnackBar(
          globalSnackBar("Some error occurred, please try again later."));
      // Add analytics to see the error
      if (kDebugMode) {
        print(e.code);
        print(e.message);
      }
    }
  }

  // Sign in with google
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // Sign in aborted by user
      return;
    }

    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState?.showSnackBar(
          globalSnackBar("Some error occurred, please try again later."));
      // Add analytics to see the error
      if (kDebugMode) {
        print(e.code);
        print(e.message);
      }
    }
  }
}
