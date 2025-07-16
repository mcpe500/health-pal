import 'package:flutter/material.dart';
import 'package:health_pal_frontend/auth/auth_service.dart';
import 'package:health_pal_frontend/screens/login_screen.dart';
import 'package:health_pal_frontend/screens/main_navigation.dart';
import 'package:health_pal_frontend/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AuthService _authService = AuthService();
  late Future<bool> _isAuthenticatedFuture;

  @override
  void initState() {
    super.initState();
    _isAuthenticatedFuture = _authService.isAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Pal',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: _isAuthenticatedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.hasData && snapshot.data == true) {
              return const MainNavigation();
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
    );
  }
}
