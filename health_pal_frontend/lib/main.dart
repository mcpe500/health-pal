import 'package:flutter/material.dart';
import 'package:health_pal_frontend/auth/auth_service.dart';
import 'package:health_pal_frontend/screens/login_screen.dart';
import 'package:health_pal_frontend/screens/home_screen.dart';
import 'package:health_pal_frontend/screens/health_plan_screen.dart'; // Import HealthPlanScreen
import 'package:health_pal_frontend/screens/reminders_screen.dart'; // Import RemindersScreen
import 'package:health_pal_frontend/screens/data_visualization_screen.dart'; // Import DataVisualizationScreen
import 'package:health_pal_frontend/screens/hp_data_collection_screen.dart'; // Import HPDataCollectionScreen

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
              return const HomeScreen(); // Or HealthPlanScreen, based on initial route
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/health_plan': (context) => const HealthPlanScreen(), // Define route for HealthPlanScreen
        '/reminders': (context) => const RemindersScreen(), // Define route for RemindersScreen
        '/data_visualization': (context) => const DataVisualizationScreen(), // Define route for DataVisualizationScreen
        '/hp_data_collection': (context) => const HPDataCollectionScreen(), // Define route for HPDataCollectionScreen
      },
    );
  }
}
