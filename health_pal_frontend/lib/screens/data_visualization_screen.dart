import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Correct import for fl_chart
import 'package:health_pal_frontend/services/step_service.dart';
import 'package:health_pal_frontend/services/sitting_time_service.dart';
import 'package:health_pal_frontend/services/nutrition_service.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:intl/intl.dart';

class DataVisualizationScreen extends StatefulWidget {
  const DataVisualizationScreen({super.key});

  @override
  State<DataVisualizationScreen> createState() => _DataVisualizationScreenState();
}

class _DataVisualizationScreenState extends State<DataVisualizationScreen> {
  final StepService _stepService = StepService(apiClient: ApiClient());
  final SittingTimeService _sittingTimeService = SittingTimeService(apiClient: ApiClient());
  final NutritionService _nutritionService = NutritionService(apiClient: ApiClient());

  String _selectedDataType = 'steps'; // Default selected data type
  List<FlSpot> _chartData = [];
  String _message = 'Select a data type to visualize.';

  @override
  void initState() {
    super.initState();
    _fetchAndVisualizeData();
  }

  Future<void> _fetchAndVisualizeData() async {
    setState(() {
      _message = 'Fetching data...';
      _chartData = [];
    });

    try {
      if (_selectedDataType == 'steps') {
        final history = await _stepService.getStepsHistory();
        _chartData = history.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.stepsCount.toDouble());
        }).toList();
        _message = history.isEmpty ? 'No step data available.' : '';
      } else if (_selectedDataType == 'sitting_time') {
        final history = await _sittingTimeService.getSittingTimeHistory();
        _chartData = history.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.durationMinutes.toDouble());
        }).toList();
        _message = history.isEmpty ? 'No sitting time data available.' : '';
      } else if (_selectedDataType == 'calories') {
        // Fetch daily nutrition summaries and extract total calories
        // This will fetch all data, you might want to implement date range filtering later
        List<Map<String, dynamic>> allSummaries = [];
        // For simplicity, fetching last 30 days. In real app, fetch all or paginated.
        for (int i = 0; i < 30; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final summary = await _nutritionService.getDailyNutritionSummary(date);
          if (summary.isNotEmpty) {
            allSummaries.add(summary);
          }
        }
        _chartData = allSummaries.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), (entry.value['total_calories'] as num).toDouble());
        }).toList();
        _message = allSummaries.isEmpty ? 'No nutrition data available.' : '';
      }

      setState(() {});
    } catch (e) {
      setState(() {
        _message = 'Error fetching data: ${e.toString()}';
      });
      debugPrint('Error fetching data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Visualization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedDataType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDataType = newValue;
                  });
                  _fetchAndVisualizeData();
                }
              },
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'steps',
                  child: Text('Steps'),
                ),
                DropdownMenuItem<String>(
                  value: 'sitting_time',
                  child: Text('Sitting Time (minutes)'),
                ),
                DropdownMenuItem<String>(
                  value: 'calories',
                  child: Text('Calories'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(_message),
            const SizedBox(height: 20),
            Expanded(
              child: _chartData.isEmpty && _message.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _chartData.isEmpty && _message.isNotEmpty
                      ? Center(child: Text(_message))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameWidget: const Text('Value'),
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: const Text('Days Ago'),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final daysAgo = _chartData.length - 1 - value.toInt();
                                    return Text('$daysAgo');
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _chartData,
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}