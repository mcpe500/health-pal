import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_pal_frontend/utils/secure_storage.dart';

// Backend API URL - **IMPORTANT: Replace with your actual backend URL**
const String backendApiUrl = 'http://localhost:8080';

class ApiClient {
  final SecureStorage _secureStorage = SecureStorage();

  // Helper for making authenticated GET requests
  Future<http.Response> get(String path) async {
    final token = await _secureStorage.getJwtToken();
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return http.get(Uri.parse('$backendApiUrl$path'), headers: headers);
  }

  // Helper for making authenticated POST requests
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await _secureStorage.getJwtToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return http.post(Uri.parse('$backendApiUrl$path'),
        headers: headers, body: jsonEncode(body));
  }

  // You can add put, delete, etc. methods here
}