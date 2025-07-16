import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';

class WaterIntakeEntry {
  final int id;
  final String date;
  final int? amountMl;
  final DateTime createdAt;

  WaterIntakeEntry({
    required this.id,
    required this.date,
    this.amountMl,
    required this.createdAt,
  });

  factory WaterIntakeEntry.fromJson(Map<String, dynamic> json) {
    return WaterIntakeEntry(
      id: json['id'],
      date: json['date'],
      amountMl: json['amount_ml'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WaterIntakeService {
  final ApiClient apiClient;

  WaterIntakeService({required this.apiClient});

  Future<bool> recordWaterIntake(String date, int amountMl) async {
    try {
      final response = await apiClient.post('/api/v1/water-intake', {
        'date': date,
        'amount_ml': amountMl,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to record water intake: $e');
    }
  }

  Future<List<WaterIntakeEntry>> getWaterIntakeHistory() async {
    try {
      final response = await apiClient.get('/api/v1/water-intake');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WaterIntakeEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch water intake history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch water intake history: $e');
    }
  }

  Future<WaterIntakeEntry?> getTodayWaterIntake() async {
    try {
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final history = await getWaterIntakeHistory();
      return history.where((entry) => entry.date == dateString).firstOrNull;
    } catch (e) {
      throw Exception('Failed to fetch today\'s water intake: $e');
    }
  }
}