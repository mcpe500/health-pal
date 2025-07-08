import 'package:flutter/material.dart';
import 'package:health_pal_frontend/services/hp_data_service.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:health/health.dart'; // Import Health package for data types

class HPDataCollectionScreen extends StatefulWidget {
  const HPDataCollectionScreen({super.key});

  @override
  State<HPDataCollectionScreen> createState() => _HPDataCollectionScreenState();
}

class _HPDataCollectionScreenState extends State<HPDataCollectionScreen> {
  final HPDataService _hpDataService = HPDataService(apiClient: ApiClient());
  String _message = 'Tap a button to collect and upload data.';

  Future<void> _requestPermissionsAndCollect(HealthDataType dataType) async {
    setState(() {
      _message = 'Requesting permissions and collecting $dataType data...';
    });

    try {
      final isAuthorized = await _hpDataService.requestPermissions();
      if (!isAuthorized) {
        setState(() {
          _message = 'Permissions not granted for $dataType. Please enable them in your phone settings.';
        });
        return;
      }

      final now = DateTime.now();
      final history = await _hpDataService.fetchData(dataType, now.subtract(const Duration(days: 7)), now);

      if (history.isEmpty) {
        setState(() {
          _message = 'No $dataType data found for the last 7 days.';
        });
        return;
      }

      await _hpDataService.uploadHealthData(history);
      setState(() {
        _message = '$dataType data collected and uploaded successfully! Found ${history.length} entries.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error collecting/uploading $dataType data: ${e.toString()}';
      });
      debugPrint('Error collecting/uploading $dataType data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HP Data Collection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.STEPS),
              child: const Text('Collect & Upload Steps'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.HEART_RATE),
              child: const Text('Collect & Upload Heart Rate'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.BODY_MASS_INDEX),
              child: const Text('Collect & Upload Body Mass Index'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.HEIGHT),
              child: const Text('Collect & Upload Height'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.ACTIVE_ENERGY_BURNED),
              child: const Text('Collect & Upload Active Energy Burned'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.DISTANCE_WALKING_RUNNING),
              child: const Text('Collect & Upload Distance Walking/Running'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.SLEEP_IN_BED),
              child: const Text('Collect & Upload Sleep in Bed'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.WEIGHT),
              child: const Text('Collect & Upload Weight'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.BODY_FAT_PERCENTAGE),
              child: const Text('Collect & Upload Body Fat Percentage'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.BASAL_ENERGY_BURNED),
              child: const Text('Collect & Upload Basal Energy Burned'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.BLOOD_PRESSURE_SYSTOLIC),
              child: const Text('Collect & Upload Blood Pressure (Systolic)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.BLOOD_PRESSURE_DIASTOLIC),
              child: const Text('Collect & Upload Blood Pressure (Diastolic)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.RESPIRATORY_RATE),
              child: const Text('Collect & Upload Respiratory Rate'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.BODY_TEMPERATURE),
              child: const Text('Collect & Upload Body Temperature'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestPermissionsAndCollect(HealthDataType.BLOOD_GLUCOSE),
              child: const Text('Collect & Upload Blood Glucose'),
            ),
          ],
        ),
      ),
    );
  }
}