import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';

class FoodAnalysisService {
  final ApiClient apiClient;

  FoodAnalysisService({required this.apiClient});

  Future<Map<String, dynamic>> requestFoodAnalysis(int foodPhotoId) async {
    final response = await apiClient.post(
      '/api/v1/food-photos/analyze',
      {'food_photo_id': foodPhotoId},
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to analyze food photo: ${response.statusCode} - ${errorBody['error']}');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodAnalysisHistory() async {
    final response = await apiClient.get('/api/v1/food-photos/analysis-history');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load food analysis history: ${response.statusCode} - ${errorBody['error']}');
    }
  }
}