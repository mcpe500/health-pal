import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

class SittingTimeService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> recordSittingTime(String date, int durationMinutes) async {
    final response = await _apiClient.post('/api/v1/sitting-times', {
      'date': date,
      'duration_minutes': durationMinutes,
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to record sitting time: ${response.body}');
      return false;
    }
  }

  Future<List<SittingTimeEntry>> getSittingTimeHistory() async {
    final response = await _apiClient.get('/api/v1/sitting-times/history');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => SittingTimeEntry.fromJson(item)).toList();
    } else {
      print('Failed to get sitting time history: ${response.body}');
      return [];
    }
  }
}

class SittingTimeEntry {
  final int id;
  final int userId;
  final String date;
  final int durationMinutes;

  SittingTimeEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.durationMinutes,
  });

  factory SittingTimeEntry.fromJson(Map<String, dynamic> json) {
    return SittingTimeEntry(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      durationMinutes: json['duration_minutes'],
    );
  }
}