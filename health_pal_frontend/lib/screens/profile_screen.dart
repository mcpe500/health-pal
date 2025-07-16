import 'package:flutter/material.dart';
import 'package:health_pal_frontend/auth/auth_service.dart';
import 'package:health_pal_frontend/screens/login_screen.dart';
import 'package:health_pal_frontend/widgets/custom_app_bar.dart';
import 'package:health_pal_frontend/utils/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();
  String _accountDeletionMessage = '';
  bool _isLoading = false;

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _requestAccountDeletionOTP() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = _authService.currentUser;
      if (googleUser == null) {
        setState(() {
          _accountDeletionMessage = 'Could not get user email for OTP request.';
          _isLoading = false;
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
        _showOTPDialog();
      } else {
        setState(() {
          _accountDeletionMessage = 'Failed to request OTP: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _accountDeletionMessage = 'Error requesting OTP: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAccountDeletionOTP(String otp) async {
    setState(() => _isLoading = true);
    try {
      final googleUser = _authService.currentUser;
      if (googleUser == null) {
        setState(() {
          _accountDeletionMessage = 'Could not get user email for OTP verification.';
          _isLoading = false;
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
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOTPDialog() {
    String otpInput = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter the OTP sent to your email:'),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => otpInput = value,
                decoration: const InputDecoration(
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _verifyAccountDeletionOTP(otpInput);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Verify & Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null,
                            child: user?.photoUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.displayName ?? 'Unknown User',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.email ?? 'No email',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Settings Section
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to notifications settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notifications settings coming soon!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('Privacy'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to privacy settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Privacy settings coming soon!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: const Text('Help & Support'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to help
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Help & Support coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Account Actions
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.orange),
                          title: const Text('Sign Out'),
                          onTap: _handleSignOut,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text('Delete Account'),
                          onTap: _requestAccountDeletionOTP,
                        ),
                      ],
                    ),
                  ),
                  
                  if (_accountDeletionMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _accountDeletionMessage,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // App Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Health Pal',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}