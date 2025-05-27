import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dantri_clone/views/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Authentication Service
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // register method
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Register error: ${e.message}');
      return null;
    }
  }

  // Sign in with Google method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('Lỗi Google Sign-In: $e');
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
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
    }
  }

  // Delete account method
  Future<bool> deleteAccount() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // Nếu user đăng nhập bằng Google, cần disconnect Google account
      if (user.providerData.any((info) => info.providerId == 'google.com')) {
        await _googleSignIn.disconnect();
      }

      // Xóa tài khoản Firebase
      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      print('Lỗi xóa tài khoản: ${e.message}');

      // Nếu cần re-authenticate
      if (e.code == 'requires-recent-login') {
        throw FirebaseAuthException(
          code: e.code,
          message: 'Vui lòng đăng nhập lại để xác nhận xóa tài khoản.',
        );
      }

      return false;
    } catch (e) {
      print('Lỗi không xác định khi xóa tài khoản: $e');
      return false;
    }
  }

  // Re-authenticate user (cần thiết cho việc xóa tài khoản)
  Future<bool> reauthenticateUser(String password) async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print('Lỗi re-authenticate: $e');
      return false;
    }
  }

  // Re-authenticate with Google
  Future<bool> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User? user = _firebaseAuth.currentUser;
      if (user == null) return false;

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print('Lỗi re-authenticate với Google: $e');
      return false;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  // Save extra profile info
  Future<void> updateUserProfileFirestore(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  // Get user profile info
  Future<Map<String, dynamic>?> getUserProfileFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}

// Authentication Gate Widget
class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

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
