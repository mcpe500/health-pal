import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:health/health.dart'; // Import the health package

class HPDataService {
  final ApiClient apiClient;
  final HealthFactory health;

  HPDataService({required this.apiClient}) : health = HealthFactory();

  Future<bool> requestPermissions() async {
    // Define the types of health data to request
    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.HEIGHT,
      HealthDataType.BODY_MASS_INDEX, // Using BMI as an example for body data
      // Add more as needed
    ];

    // Request permissions
    bool authorized = await health.requestAuthorization(types);
    return authorized;
  }

  Future<List<HealthDataPoint>> fetchData(HealthDataType type, DateTime startDate, DateTime endDate) async {
    bool authorized = await requestPermissions(); // Ensure permissions are granted
    if (!authorized) {
      throw Exception('Health permissions not granted.');
    }
    return await health.getHealthDataFromTypes(startDate, endDate, [type]);
  }

  Future<void> uploadHealthData(List<HealthDataPoint> data) async {
    final List<Map<String, dynamic>> dataToUpload = data.map((point) => {
      'data_type': point.type.name,
      'value': point.value,
      'unit': point.unit.name,
      'timestamp': point.dateFrom.toIso8601String(),
    }).toList();

    final response = await apiClient.post('/api/v1/hp-data/upload', {'data': dataToUpload});

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to upload HP data: ${response.statusCode} - ${errorBody['error']}');
    }
  }

  Future<List<Map<String, dynamic>>> getHPDataHistory({String? dataType, DateTime? startDate, DateTime? endDate}) async {
    Map<String, dynamic> queryParams = {};
    if (dataType != null) queryParams['data_type'] = dataType;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

    final response = await apiClient.get('/api/v1/hp-data/history', queryParams: queryParams);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load HP data history: ${response.statusCode} - ${errorBody['error']}');
    }
  }
}