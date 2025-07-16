import 'package:flutter/material.dart';
import 'package:health_pal_frontend/widgets/custom_app_bar.dart';
import 'package:health_pal_frontend/widgets/loading_overlay.dart';
import 'package:health_pal_frontend/services/step_service.dart';
import 'package:health_pal_frontend/services/sitting_time_service.dart';
import 'package:health_pal_frontend/services/water_intake_service.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:intl/intl.dart';

class HealthTrackingScreen extends StatefulWidget {
  const HealthTrackingScreen({super.key});

  @override
  State<HealthTrackingScreen> createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final StepService _stepService = StepService(apiClient: ApiClient());
  final SittingTimeService _sittingTimeService = SittingTimeService(apiClient: ApiClient());
  final WaterIntakeService _waterIntakeService = WaterIntakeService(apiClient: ApiClient());

  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _sittingTimeController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();

  List<StepEntry> _stepHistory = [];
  List<SittingTimeEntry> _sittingTimeHistory = [];
  List<WaterIntakeEntry> _waterHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stepsController.dispose();
    _sittingTimeController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadStepHistory(),
        _loadSittingTimeHistory(),
        _loadWaterHistory(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStepHistory() async {
    try {
      final history = await _stepService.getStepsHistory();
      setState(() {
        _stepHistory = history;
      });
    } catch (e) {
      debugPrint('Error loading step history: $e');
    }
  }

  Future<void> _loadSittingTimeHistory() async {
    try {
      final history = await _sittingTimeService.getSittingTimeHistory();
      setState(() {
        _sittingTimeHistory = history;
      });
    } catch (e) {
      debugPrint('Error loading sitting time history: $e');
    }
  }

  Future<void> _loadWaterHistory() async {
    try {
      final history = await _waterIntakeService.getWaterIntakeHistory();
      setState(() {
        _waterHistory = history;
      });
    } catch (e) {
      debugPrint('Error loading water history: $e');
    }
  }

  Future<void> _recordSteps() async {
    final stepsText = _stepsController.text.trim();
    if (stepsText.isEmpty) {
      _showSnackBar('Please enter number of steps');
      return;
    }

    final steps = int.tryParse(stepsText);
    if (steps == null || steps < 0) {
      _showSnackBar('Please enter a valid number of steps');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final success = await _stepService.recordSteps(date, steps);
      
      if (success) {
        _showSnackBar('Steps recorded successfully!');
        _stepsController.clear();
        await _loadStepHistory();
      } else {
        _showSnackBar('Failed to record steps');
      }
    } catch (e) {
      _showSnackBar('Error recording steps: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _recordSittingTime() async {
    final timeText = _sittingTimeController.text.trim();
    if (timeText.isEmpty) {
      _showSnackBar('Please enter sitting time in minutes');
      return;
    }

    final minutes = int.tryParse(timeText);
    if (minutes == null || minutes < 0) {
      _showSnackBar('Please enter a valid number of minutes');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final success = await _sittingTimeService.recordSittingTime(date, minutes);
      
      if (success) {
        _showSnackBar('Sitting time recorded successfully!');
        _sittingTimeController.clear();
        await _loadSittingTimeHistory();
      } else {
        _showSnackBar('Failed to record sitting time');
      }
    } catch (e) {
      _showSnackBar('Error recording sitting time: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _recordWaterIntake() async {
    final waterText = _waterController.text.trim();
    if (waterText.isEmpty) {
      _showSnackBar('Please enter water amount in ml');
      return;
    }

    final amount = int.tryParse(waterText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount in ml');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final success = await _waterIntakeService.recordWaterIntake(date, amount);
      
      if (success) {
        _showSnackBar('Water intake recorded successfully!');
        _waterController.clear();
        await _loadWaterHistory();
      } else {
        _showSnackBar('Failed to record water intake');
      }
    } catch (e) {
      _showSnackBar('Error recording water intake: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Processing...',
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Health Tracking',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAllData,
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'Steps', icon: Icon(Icons.directions_walk)),
                Tab(text: 'Sitting', icon: Icon(Icons.chair)),
                Tab(text: 'Water', icon: Icon(Icons.water_drop)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStepsTab(),
                  _buildSittingTimeTab(),
                  _buildWaterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard(
            title: 'Record Today\'s Steps',
            controller: _stepsController,
            hintText: 'Enter number of steps',
            keyboardType: TextInputType.number,
            onSubmit: _recordSteps,
            icon: Icons.directions_walk,
          ),
          const SizedBox(height: 24),
          Text(
            'Step History',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _stepHistory.isEmpty
                ? const Center(child: Text('No step data available'))
                : ListView.builder(
                    itemCount: _stepHistory.length,
                    itemBuilder: (context, index) {
                      final step = _stepHistory[index];
                      return _buildHistoryCard(
                        date: step.date,
                        value: '${step.stepsCount} steps',
                        icon: Icons.directions_walk,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSittingTimeTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard(
            title: 'Record Sitting Time',
            controller: _sittingTimeController,
            hintText: 'Enter minutes spent sitting',
            keyboardType: TextInputType.number,
            onSubmit: _recordSittingTime,
            icon: Icons.chair,
          ),
          const SizedBox(height: 24),
          Text(
            'Sitting Time History',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _sittingTimeHistory.isEmpty
                ? const Center(child: Text('No sitting time data available'))
                : ListView.builder(
                    itemCount: _sittingTimeHistory.length,
                    itemBuilder: (context, index) {
                      final sitting = _sittingTimeHistory[index];
                      return _buildHistoryCard(
                        date: sitting.date,
                        value: '${sitting.durationMinutes} minutes',
                        icon: Icons.chair,
                        color: Colors.orange,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard(
            title: 'Record Water Intake',
            controller: _waterController,
            hintText: 'Enter amount in ml',
            keyboardType: TextInputType.number,
            onSubmit: _recordWaterIntake,
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 24),
          Text(
            'Water Intake History',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _waterHistory.isEmpty
                ? const Center(child: Text('No water intake data available'))
                : ListView.builder(
                    itemCount: _waterHistory.length,
                    itemBuilder: (context, index) {
                      final water = _waterHistory[index];
                      return _buildHistoryCard(
                        date: water.date,
                        value: '${water.amountMl} ml',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required VoidCallback onSubmit,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onSubmit,
                ),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.save),
                label: const Text('Record'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(value),
        subtitle: Text('Date: $date'),
        trailing: Icon(
          Icons.check_circle,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}