import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_pal_frontend/auth/auth_service.dart';
import 'package:health_pal_frontend/screens/login_screen.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_pal_frontend/auth/auth_service.dart';
import 'package:health_pal_frontend/screens/login_screen.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:health_pal_frontend/services/step_service.dart'; // Import StepService
import 'package:health_pal_frontend/services/sitting_time_service.dart'; // Import SittingTimeService
import 'package:intl/intl.dart'; // For date formatting

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();
  final StepService _stepService = StepService(); // Initialize StepService
  final SittingTimeService _sittingTimeService = SittingTimeService(); // Initialize SittingTimeService
  String _protectedDataMessage = 'Fetching protected data...';
  String _accountDeletionMessage = '';
  final TextEditingController _stepsController = TextEditingController(); // Controller for step input
  final TextEditingController _sittingTimeController = TextEditingController(); // Controller for sitting time input
  List<StepEntry> _stepHistory = []; // List to store step history
  List<SittingTimeEntry> _sittingTimeHistory = []; // List to store sitting time history

  @override
  void initState() {
    super.initState();
    _fetchProtectedData();
    _fetchStepHistory(); // Fetch step history on init
    _fetchSittingTimeHistory(); // Fetch sitting time history on init
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _sittingTimeController.dispose();
    super.dispose();
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

  Future<void> _fetchStepHistory() async {
    try {
      final history = await _stepService.getStepsHistory();
      setState(() {
        _stepHistory = history;
      });
    } catch (e) {
      debugPrint('Error fetching step history: ${e.toString()}');
    }
  }

  Future<void> _fetchSittingTimeHistory() async {
    try {
      final history = await _sittingTimeService.getSittingTimeHistory();
      setState(() {
        _sittingTimeHistory = history;
      });
    } catch (e) {
      debugPrint('Error fetching sitting time history: ${e.toString()}');
    }
  }

  Future<void> _recordSteps() async {
    final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final int? stepsCount = int.tryParse(_stepsController.text);

    if (stepsCount == null || stepsCount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of steps.')),
      );
      return;
    }

    try {
      final success = await _stepService.recordSteps(date, stepsCount);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Steps recorded successfully!')),
        );
        _stepsController.clear();
        _fetchStepHistory(); // Refresh history
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to record steps.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording steps: ${e.toString()}')),
      );
      debugPrint('Error recording steps: ${e.toString()}');
    }
  }

  Future<void> _recordSittingTime() async {
    final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final int? durationMinutes = int.tryParse(_sittingTimeController.text);

    if (durationMinutes == null || durationMinutes < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration in minutes.')),
      );
      return;
    }

    try {
      final success = await _sittingTimeService.recordSittingTime(date, durationMinutes);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sitting time recorded successfully!')),
        );
        _sittingTimeController.clear();
        _fetchSittingTimeHistory(); // Refresh history
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to record sitting time.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording sitting time: ${e.toString()}')),
      );
      debugPrint('Error recording sitting time: ${e.toString()}');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 40),
            const Text('Track Your Steps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter daily steps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _recordSteps,
              child: const Text('Record Steps'),
            ),
            const SizedBox(height: 20),
            const Text('Step History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _stepHistory.isEmpty
                  ? const Center(child: Text('No step data available.'))
                  : ListView.builder(
                      itemCount: _stepHistory.length,
                      itemBuilder: (context, index) {
                        final step = _stepHistory[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text('Date: ${step.date}'),
                            trailing: Text('${step.stepsCount} steps'),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 40),
            const Text('Track Your Sitting Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _sittingTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter daily sitting time (minutes)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _recordSittingTime,
              child: const Text('Record Sitting Time'),
            ),
            const SizedBox(height: 20),
            const Text('Sitting Time History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _sittingTimeHistory.isEmpty
                  ? const Center(child: Text('No sitting time data available.'))
                  : ListView.builder(
                      itemCount: _sittingTimeHistory.length,
                      itemBuilder: (context, index) {
                        final sittingTime = _sittingTimeHistory[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text('Date: ${sittingTime.date}'),
                            trailing: Text('${sittingTime.durationMinutes} minutes'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}