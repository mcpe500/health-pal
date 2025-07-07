import 'package:flutter/material.dart';
import 'package:health_pal_frontend/auth/auth_service.dart';
import 'package:health_pal_frontend/screens/home_screen.dart'; // Will create this next

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  String _message = '';

  Future<void> _handleSignIn() async {
    setState(() {
      _message = 'Signing in...';
    });
    try {
      final String? jwtToken = await _authService.signInWithGoogle();
      if (jwtToken != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _message = 'Sign-in cancelled.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error during sign-in: ${e.toString()}';
      });
      debugPrint('Error during sign-in: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Pal Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}