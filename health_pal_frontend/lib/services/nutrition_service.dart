import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';

class NutritionService {
  final ApiClient apiClient;

  NutritionService({required this.apiClient});

  Future<Map<String, dynamic>> getDailyNutritionSummary(DateTime date) async {
    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await apiClient.get('/api/v1/nutrition/daily-summary?date=$formattedDate');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {}; // Return empty if no summary for the day
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load daily nutrition summary: ${response.statusCode} - ${errorBody['error']}');
    }
  }

  Future<void> logManualNutrition(Map<String, dynamic> nutritionData) async {
    final response = await apiClient.post('/api/v1/nutrition/manual-entry', nutritionData);

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to log manual nutrition: ${response.statusCode} - ${errorBody['error']}');
    }
  }
}