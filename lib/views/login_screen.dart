import 'package:dantri_clone/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Login Page
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _login() async {
    final credential = await _authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (credential != null) {
      // Navigate to home page or main app
      context.go('/home');
    } else {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}
