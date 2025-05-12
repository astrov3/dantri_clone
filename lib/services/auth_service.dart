import 'package:dantri_clone/views/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Authentication Service
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  // Sign in method
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      return null;
    }
  }
  // Sign in with Google method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      return await _firebaseAuth.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      print('Sign in with Google error: ${e.message}');
      return null;
    }
  }

  // Sign up method
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;
}

// Authentication Gate Widget
class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Showing loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is not authenticated, redirect to login
        if (snapshot.data == null) {
          return LoginScreen();
        }

        // User is authenticated, show the child widget
        return child;
      },
    );
  }
}
