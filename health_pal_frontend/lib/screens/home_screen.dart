import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_pal_frontend/auth/auth_service.dart';
import 'package:health_pal_frontend/screens/login_screen.dart';
import 'package:health_pal_frontend/utils/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();
  String _protectedDataMessage = 'Fetching protected data...';
  String _accountDeletionMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProtectedData();
  }

  Future<void> _fetchProtectedData() async {
    try {
      final response = await _apiClient.get('/api/v1/profile');
      if (response.statusCode == 200) {
        setState(() {
          _protectedDataMessage = 'Protected data: ${response.body}';
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _protectedDataMessage = 'Protected data access denied: Invalid or expired token.';
        });
        _handleSignOut(); // Log out if token is invalid/expired
      } else {
        setState(() {
          _protectedDataMessage = 'Failed to fetch protected data: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _protectedDataMessage = 'Error fetching protected data: ${e.toString()}';
      });
      debugPrint('Error fetching protected data: ${e.toString()}');
    }
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _requestAccountDeletionOTP() async {
    try {
      final GoogleSignInAccount? googleUser = _authService.currentUser;
      if (googleUser == null) {
        setState(() {
          _accountDeletionMessage = 'Could not get Google user email for OTP request.';
        });
        return;
      }

      final response = await _apiClient.post(
        '/api/v1/delete-account/request-otp',
        {'email': googleUser.email},
      );

      if (response.statusCode == 200) {
        setState(() {
          _accountDeletionMessage = 'OTP sent to ${googleUser.email}. Please verify.';
        });
        // Optionally navigate to a dedicated OTP verification screen here
      } else {
        setState(() {
          _accountDeletionMessage = 'Failed to request OTP: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _accountDeletionMessage = 'Error requesting OTP: ${e.toString()}';
      });
      debugPrint('Error requesting OTP: ${e.toString()}');
    }
  }

  Future<void> _verifyAccountDeletionOTP(String otp) async {
    try {
      final GoogleSignInAccount? googleUser = _authService.currentUser;
      if (googleUser == null) {
        setState(() {
          _accountDeletionMessage = 'Could not get Google user email for OTP verification.';
        });
        return;
      }

      final response = await _apiClient.post(
        '/api/v1/delete-account/verify-otp',
        {'email': googleUser.email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        setState(() {
          _accountDeletionMessage = 'Account successfully deleted!';
        });
        await _authService.signOut(); // Log out after successful deletion
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        setState(() {
          _accountDeletionMessage = 'Failed to verify OTP or delete account: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _accountDeletionMessage = 'Error verifying OTP: ${e.toString()}';
      });
      debugPrint('Error verifying OTP: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Pal Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_protectedDataMessage),
            const SizedBox(height: 20),
            Text(_accountDeletionMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestAccountDeletionOTP,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Request Account Deletion OTP'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String otpInput = '';
                    return AlertDialog(
                      title: const Text('Enter OTP'),
                      content: TextField(
                        onChanged: (value) {
                          otpInput = value;
                        },
                        decoration: const InputDecoration(hintText: 'Enter OTP'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _verifyAccountDeletionOTP(otpInput);
                          },
                          child: const Text('Verify & Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Verify OTP & Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}