import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';

class HealthPlanService {
  final ApiClient apiClient;

  HealthPlanService({required this.apiClient});

  Future<Map<String, dynamic>> generateHealthPlan(String goals) async {
    final response = await apiClient.post(
      '/api/v1/health-plan/generate',
      {'goals': goals},
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to generate health plan: ${response.statusCode} - ${errorBody['error']}');
    }
  }

  Future<Map<String, dynamic>> getHealthPlan() async {
    final response = await apiClient.get('/api/v1/health-plan');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {}; // Return empty if no plan found
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load health plan: ${response.statusCode} - ${errorBody['error']}');
    }
  }
}