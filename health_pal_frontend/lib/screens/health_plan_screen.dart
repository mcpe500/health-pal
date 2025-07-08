import 'package:flutter/material.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:health_pal_frontend/services/health_plan_service.dart';
import 'dart:convert'; // For jsonDecode

class HealthPlanScreen extends StatefulWidget {
  const HealthPlanScreen({super.key});

  @override
  State<HealthPlanScreen> createState() => _HealthPlanScreenState();
}

class _HealthPlanScreenState extends State<HealthPlanScreen> {
  final HealthPlanService _healthPlanService = HealthPlanService(apiClient: ApiClient());
  final TextEditingController _goalsController = TextEditingController();
  Map<String, dynamic> _healthPlan = {};
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchHealthPlan();
  }

  @override
  void dispose() {
    _goalsController.dispose();
    super.dispose();
  }

  Future<void> _fetchHealthPlan() async {
    try {
      final plan = await _healthPlanService.getHealthPlan();
      setState(() {
        _healthPlan = plan;
        _message = plan.isEmpty ? 'No health plan found. Generate one below!' : '';
      });
    } catch (e) {
      setState(() {
        _message = 'Error fetching health plan: ${e.toString()}';
      });
      debugPrint('Error fetching health plan: ${e.toString()}');
    }
  }

  Future<void> _generateHealthPlan() async {
    if (_goalsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your health goals.')),
      );
      return;
    }

    setState(() {
      _message = 'Generating health plan...';
    });

    try {
      final newPlan = await _healthPlanService.generateHealthPlan(_goalsController.text);
      setState(() {
        _healthPlan = newPlan;
        _message = 'Health plan generated successfully!';
      });
      _goalsController.clear();
    } catch (e) {
      setState(() {
        _message = 'Failed to generate health plan: ${e.toString()}';
      });
      debugPrint('Error generating health plan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_message),
            const SizedBox(height: 20),
            TextField(
              controller: _goalsController,
              decoration: const InputDecoration(
                labelText: 'Enter your health goals (e.g., Weight Loss, Muscle Gain)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _generateHealthPlan,
              child: const Text('Generate Health Plan'),
            ),
            const SizedBox(height: 40),
            if (_healthPlan.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Personalized Health Plan:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Goal: ${_healthPlan['goal'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      if (_healthPlan['plan_details'] != null && _healthPlan['plan_details'] is String)
                        _buildPlanDetails(jsonDecode(_healthPlan['plan_details'])),
                      const SizedBox(height: 20),
                      Text('Generated On: ${DateTime.parse(_healthPlan['generated_date']).toLocal().toString().split('.')[0]}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetails(Map<String, dynamic> planDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (planDetails['summary'] != null) ...[
          const Text('Summary:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(planDetails['summary']),
          const SizedBox(height: 10),
        ],
        if (planDetails['dietary_recommendations'] != null) ...[
          const Text('Dietary Recommendations:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(planDetails['dietary_recommendations']),
          const SizedBox(height: 10),
        ],
        if (planDetails['exercise_suggestions'] != null) ...[
          const Text('Exercise Suggestions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(planDetails['exercise_suggestions']),
          const SizedBox(height: 10),
        ],
        if (planDetails['lifestyle_tips'] != null) ...[
          const Text('Lifestyle Tips:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(planDetails['lifestyle_tips']),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}