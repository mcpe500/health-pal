import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';

class ReminderService {
  final ApiClient apiClient;

  ReminderService({required this.apiClient});

  Future<void> scheduleReminder(Map<String, dynamic> reminderData) async {
    final response = await apiClient.post('/api/v1/reminders/schedule', reminderData);

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to schedule reminder: ${response.statusCode} - ${errorBody['error']}');
    }
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final response = await apiClient.get('/api/v1/reminders');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load reminders: ${response.statusCode} - ${errorBody['error']}');
    }
  }
}