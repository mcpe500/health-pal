import 'package:flutter/material.dart';
import 'package:health_pal_frontend/widgets/custom_app_bar.dart';
import 'package:health_pal_frontend/widgets/health_card.dart';
import 'package:health_pal_frontend/theme/app_theme.dart';
import 'package:health_pal_frontend/services/step_service.dart';
import 'package:health_pal_frontend/services/nutrition_service.dart';
import 'package:health_pal_frontend/services/water_intake_service.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StepService _stepService = StepService(apiClient: ApiClient());
  final NutritionService _nutritionService = NutritionService(apiClient: ApiClient());
  final WaterIntakeService _waterIntakeService = WaterIntakeService(apiClient: ApiClient());

  int _todaySteps = 0;
  double _todayCalories = 0;
  double _todayWater = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now();
      
      // Load today's steps
      final stepHistory = await _stepService.getStepsHistory();
      final todayStep = stepHistory.where((step) => 
        step.date == DateFormat('yyyy-MM-dd').format(today)
      ).firstOrNull;
      _todaySteps = todayStep?.stepsCount ?? 0;

      // Load today's nutrition
      final nutritionSummary = await _nutritionService.getDailyNutritionSummary(today);
      _todayCalories = nutritionSummary['total_calories']?.toDouble() ?? 0;

      // Load today's water intake
      final waterHistory = await _waterIntakeService.getWaterIntakeHistory();
      final todayWater = waterHistory.where((water) => 
        water.date == DateFormat('yyyy-MM-dd').format(today)
      ).firstOrNull;
      _todayWater = todayWater?.amountMl?.toDouble() ?? 0;

    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Health Dashboard',
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Today's Overview
              Text(
                'Today\'s Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Health Cards Grid
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                _buildHealthCardsGrid(),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildQuickActions(),

              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.healthGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s keep track of your health journey today',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCardsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        HealthCard(
          title: 'Steps Today',
          value: _todaySteps.toString(),
          unit: 'steps',
          icon: Icons.directions_walk,
          gradient: AppTheme.activityGradient,
          onTap: () {
            // Navigate to health tracking screen
          },
        ),
        HealthCard(
          title: 'Calories',
          value: _todayCalories.toStringAsFixed(0),
          unit: 'kcal',
          icon: Icons.local_fire_department,
          gradient: AppTheme.nutritionGradient,
          onTap: () {
            // Navigate to nutrition screen
          },
        ),
        HealthCard(
          title: 'Water Intake',
          value: (_todayWater / 1000).toStringAsFixed(1),
          unit: 'L',
          icon: Icons.water_drop,
          gradient: AppTheme.healthGradient,
          onTap: () {
            // Navigate to health tracking screen
          },
        ),
        HealthCard(
          title: 'Health Score',
          value: _calculateHealthScore().toString(),
          unit: '/100',
          icon: Icons.favorite,
          gradient: const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFFF06292)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {
            // Navigate to health plan screen
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Log Food',
            Icons.camera_alt,
            AppTheme.nutritionGradient,
            () {
              // Navigate to nutrition screen
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Add Steps',
            Icons.add,
            AppTheme.activityGradient,
            () {
              // Navigate to health tracking screen
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'View Plans',
            Icons.assignment,
            AppTheme.healthGradient,
            () {
              // Navigate to health plan screen
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to data visualization screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              'Steps logged',
              '5 days ago',
              Icons.directions_walk,
              AppTheme.primaryGreen,
            ),
            _buildActivityItem(
              'Food photo analyzed',
              '2 days ago',
              Icons.restaurant,
              AppTheme.secondaryBlue,
            ),
            _buildActivityItem(
              'Health plan updated',
              '1 day ago',
              Icons.health_and_safety,
              AppTheme.accentOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateHealthScore() {
    // Simple health score calculation based on available data
    int score = 0;
    
    // Steps contribution (max 40 points)
    if (_todaySteps >= 10000) {
      score += 40;
    } else if (_todaySteps >= 5000) {
      score += 20;
    } else if (_todaySteps > 0) {
      score += 10;
    }

    // Calories contribution (max 30 points)
    if (_todayCalories >= 1500 && _todayCalories <= 2500) {
      score += 30;
    } else if (_todayCalories > 0) {
      score += 15;
    }

    // Water contribution (max 30 points)
    if (_todayWater >= 2000) {
      score += 30;
    } else if (_todayWater >= 1000) {
      score += 15;
    } else if (_todayWater > 0) {
      score += 10;
    }

    return score;
  }
}