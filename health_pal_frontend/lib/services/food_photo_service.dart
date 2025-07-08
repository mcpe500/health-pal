import 'dart:convert'; // Import for jsonDecode
import 'dart:io';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;

class FoodPhotoService {
  final ApiClient apiClient;

  FoodPhotoService({required this.apiClient});

  Future<void> uploadFoodPhoto(File imageFile, {String? description, String? mealType}) async {
    final url = Uri.parse('${apiClient.baseUrl}/api/v1/food-photos/upload');
    var request = http.MultipartRequest('POST', url);

    // Add authorization header
    final token = await apiClient.secureStorage.getJwtToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add image file
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    // Add optional fields
    if (description != null) {
      request.fields['description'] = description;
    }
    if (mealType != null) {
      request.fields['meal_type'] = mealType;
    }

    final response = await request.send();

    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Failed to upload food photo: ${response.statusCode} - $responseBody');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodPhotoHistory() async {
    final response = await apiClient.get('/api/v1/food-photos/history');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load food photo history');
    }
  }
}