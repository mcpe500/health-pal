import 'package:flutter/material.dart';
import 'package:health_pal_frontend/widgets/health_card.dart';
import 'package:health_pal_frontend/widgets/stat_card.dart';
import 'package:health_pal_frontend/widgets/section_header.dart';
import 'package:health_pal_frontend/widgets/modern_button.dart';
import 'package:health_pal_frontend/theme/app_theme.dart';
import 'package:health_pal_frontend/services/step_service.dart';
import 'package:health_pal_frontend/services/nutrition_service.dart';
import 'package:health_pal_frontend/services/water_intake_service.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:intl/intl.dart';

class ImprovedDashboardScreen extends StatefulWidget {
  const ImprovedDashboardScreen({super.key});

  @override
  State<ImprovedDashboardScreen> createState() => _ImprovedDashboardScreenState();
}

class _ImprovedDashboardScreenState extends State<ImprovedDashboardScreen>
    with TickerProviderStateMixin {
  final StepService _stepService = StepService(apiClient: ApiClient());
  final NutritionService _nutritionService = NutritionService(apiClient: ApiClient());
  final WaterIntakeService _waterIntakeService = WaterIntakeService(apiClient: ApiClient());

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _todaySteps = 0;
  double _todayCalories = 0;
  double _todayWater = 0;
  bool _isLoading = true;

  // Goals
  final int _stepGoal = 10000;
  final double _calorieGoal = 2000;
  final double _waterGoal = 2000; // ml

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDashboardData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now();
      
      // Load today's data
      await Future.wait([
        _loadStepsData(today),
        _loadNutritionData(today),
        _loadWaterData(today),
      ]);

      // Start animations
      _fadeController.forward();
      _slideController.forward();

    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStepsData(DateTime date) async {
    try {
      final stepHistory = await _stepService.getStepsHistory();
      final todayStep = stepHistory.where((step) => 
        step.date == DateFormat('yyyy-MM-dd').format(date)
      ).firstOrNull;
      _todaySteps = todayStep?.stepsCount ?? 0;
    } catch (e) {
      debugPrint('Error loading steps: $e');
    }
  }

  Future<void> _loadNutritionData(DateTime date) async {
    try {
      final nutritionSummary = await _nutritionService.getDailyNutritionSummary(date);
      _todayCalories = nutritionSummary['total_calories']?.toDouble() ?? 0;
    } catch (e) {
      debugPrint('Error loading nutrition: $e');
    }
  }

  Future<void> _loadWaterData(DateTime date) async {
    try {
      final waterHistory = await _waterIntakeService.getWaterIntakeHistory();
      final todayWater = waterHistory.where((water) => 
        water.date == DateFormat('yyyy-MM-dd').format(date)
      ).firstOrNull;
      _todayWater = todayWater?.amountMl?.toDouble() ?? 0;
    } catch (e) {
      debugPrint('Error loading water: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppTheme.primaryGreen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Custom App Bar
              _buildSliverAppBar(),
              
              // Main Content
              SliverToBoxAdapter(
                child: _isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              // Health Overview Cards
                              _buildHealthOverview(),
                              
                              const SizedBox(height: 32),
                              
                              // Today's Stats
                              _buildTodayStats(),
                              
                              const SizedBox(height: 32),
                              
                              // Quick Actions
                              _buildQuickActions(),
                              
                              const SizedBox(height: 32),
                              
                              // Recent Activity
                              _buildRecentActivity(),
                              
                              const SizedBox(height: 100), // Bottom padding
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Let\'s check your health progress',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {
            // Navigate to profile
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: 16),
            Text(
              'Loading your health data...',
              style: TextStyle(
                color: AppTheme.textMedium,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          HealthCard(
            title: 'Steps Today',
            value: _todaySteps.toString(),
            unit: 'steps',
            icon: Icons.directions_walk,
            gradient: AppTheme.activityGradient,
            progress: _todaySteps / _stepGoal,
            subtitle: 'Goal: ${_stepGoal.toString()}',
            onTap: () {
              // Navigate to health tracking
            },
          ),
          HealthCard(
            title: 'Calories',
            value: _todayCalories.toStringAsFixed(0),
            unit: 'kcal',
            icon: Icons.local_fire_department,
            gradient: AppTheme.nutritionGradient,
            progress: _todayCalories / _calorieGoal,
            subtitle: 'Goal: ${_calorieGoal.toStringAsFixed(0)}',
            onTap: () {
              // Navigate to nutrition
            },
          ),
          HealthCard(
            title: 'Water Intake',
            value: (_todayWater / 1000).toStringAsFixed(1),
            unit: 'L',
            icon: Icons.water_drop,
            gradient: AppTheme.healthGradient,
            progress: _todayWater / _waterGoal,
            subtitle: 'Goal: ${(_waterGoal / 1000).toStringAsFixed(1)}L',
            onTap: () {
              // Navigate to health tracking
            },
          ),
          HealthCard(
            title: 'Health Score',
            value: _calculateHealthScore().toString(),
            unit: '/100',
            icon: Icons.favorite,
            gradient: AppTheme.planGradient,
            progress: _calculateHealthScore() / 100,
            subtitle: _getHealthScoreText(),
            onTap: () {
              // Navigate to health plan
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      children: [
        const SectionHeader(
          title: 'Today\'s Summary',
          subtitle: 'Your daily health metrics',
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              StatCard(
                title: 'Active Minutes',
                value: '${(_todaySteps * 0.01).toInt()} min',
                subtitle: 'Based on step count',
                icon: Icons.timer,
                iconColor: AppTheme.accentOrange,
              ),
              const SizedBox(height: 12),
              StatCard(
                title: 'Calories Burned',
                value: '${(_todaySteps * 0.04).toInt()} kcal',
                subtitle: 'From walking',
                icon: Icons.whatshot,
                iconColor: AppTheme.errorRed,
              ),
              const SizedBox(height: 12),
              StatCard(
                title: 'Hydration Level',
                value: '${((_todayWater / _waterGoal) * 100).toInt()}%',
                subtitle: 'Daily goal progress',
                icon: Icons.opacity,
                iconColor: AppTheme.secondaryBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        const SectionHeader(
          title: 'Quick Actions',
          subtitle: 'Log your activities',
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: 'Log Food',
                  icon: Icons.camera_alt,
                  type: ModernButtonType.primary,
                  onPressed: () {
                    // Navigate to nutrition screen
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernButton(
                  text: 'Add Water',
                  icon: Icons.water_drop,
                  type: ModernButtonType.outline,
                  onPressed: () {
                    // Show water intake dialog
                    _showWaterIntakeDialog();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: 'Record Steps',
                  icon: Icons.directions_walk,
                  type: ModernButtonType.secondary,
                  onPressed: () {
                    // Navigate to health tracking
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernButton(
                  text: 'View Plans',
                  icon: Icons.assignment,
                  type: ModernButtonType.text,
                  onPressed: () {
                    // Navigate to health plans
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        SectionHeader(
          title: 'Recent Activity',
          subtitle: 'Your latest health logs',
          actionText: 'View All',
          actionIcon: Icons.arrow_forward,
          onActionPressed: () {
            // Navigate to activity history
          },
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Steps logged',
                '${_todaySteps} steps recorded',
                '2 hours ago',
                Icons.directions_walk,
                AppTheme.primaryGreen,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                'Water intake',
                '${(_todayWater / 1000).toStringAsFixed(1)}L consumed',
                '4 hours ago',
                Icons.water_drop,
                AppTheme.secondaryBlue,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                'Nutrition logged',
                '${_todayCalories.toStringAsFixed(0)} kcal tracked',
                '6 hours ago',
                Icons.restaurant,
                AppTheme.accentOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showWaterIntakeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water Intake'),
        content: const Text('Quick water logging feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  int _calculateHealthScore() {
    int score = 0;
    
    // Steps contribution (max 40 points)
    if (_todaySteps >= _stepGoal) {
      score += 40;
    } else if (_todaySteps >= _stepGoal * 0.5) {
      score += 20;
    } else if (_todaySteps > 0) {
      score += 10;
    }

    // Calories contribution (max 30 points)
    if (_todayCalories >= _calorieGoal * 0.8 && _todayCalories <= _calorieGoal * 1.2) {
      score += 30;
    } else if (_todayCalories > 0) {
      score += 15;
    }

    // Water contribution (max 30 points)
    if (_todayWater >= _waterGoal) {
      score += 30;
    } else if (_todayWater >= _waterGoal * 0.5) {
      score += 15;
    } else if (_todayWater > 0) {
      score += 10;
    }

    return score;
  }

  String _getHealthScoreText() {
    final score = _calculateHealthScore();
    if (score >= 80) {
      return 'Excellent!';
    } else if (score >= 60) {
      return 'Good progress';
    } else if (score >= 40) {
      return 'Keep going';
    } else {
      return 'Let\'s improve';
    }
  }
}