import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

class StepService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> recordSteps(String date, int stepsCount) async {
    final response = await _apiClient.post('/api/v1/steps', {
      'date': date,
      'steps_count': stepsCount,
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle error, e.g., print error message or throw exception
      print('Failed to record steps: ${response.body}');
      return false;
    }
  }

  Future<List<StepEntry>> getStepsHistory() async {
    final response = await _apiClient.get('/api/v1/steps/history');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => StepEntry.fromJson(item)).toList();
    } else {
      // Handle error
      print('Failed to get steps history: ${response.body}');
      return [];
    }
  }
}

class StepEntry {
  final int id;
  final int userId;
  final String date;
  final int stepsCount;

  StepEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.stepsCount,
  });

  factory StepEntry.fromJson(Map<String, dynamic> json) {
    return StepEntry(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      stepsCount: json['steps_count'],
    );
  }
}