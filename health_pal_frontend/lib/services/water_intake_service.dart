import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

class WaterIntakeService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> recordWaterIntake(String date, int amountML) async {
    final response = await _apiClient.post('/api/v1/water-intakes', {
      'date': date,
      'amount_ml': amountML,
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to record water intake: ${response.body}');
      return false;
    }
  }

  Future<List<WaterIntakeEntry>> getWaterIntakeHistory() async {
    final response = await _apiClient.get('/api/v1/water-intakes/history');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => WaterIntakeEntry.fromJson(item)).toList();
    } else {
      print('Failed to get water intake history: ${response.body}');
      return [];
    }
  }
}

class WaterIntakeEntry {
  final int id;
  final int userId;
  final String date;
  final int amountML;

  WaterIntakeEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.amountML,
  });

  factory WaterIntakeEntry.fromJson(Map<String, dynamic> json) {
    return WaterIntakeEntry(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      amountML: json['amount_ml'],
    );
  }
}