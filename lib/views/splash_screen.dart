import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      // final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      // context.go(isLoggedIn ? '/home' : '/login');
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logo.png',
              width: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Image.asset('assets/logo/Dantri_150x58.png', width: 100),
          ],
        ),
      ),
    );
  }
}
