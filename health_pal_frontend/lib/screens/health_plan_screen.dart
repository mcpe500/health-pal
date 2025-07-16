import 'package:flutter/material.dart';
import 'package:health_pal_frontend/widgets/custom_app_bar.dart';
import 'package:health_pal_frontend/widgets/section_header.dart';
import 'package:health_pal_frontend/widgets/stat_card.dart';
import 'package:health_pal_frontend/widgets/modern_button.dart';
import 'package:health_pal_frontend/theme/app_theme.dart';

class HealthPlanScreen extends StatefulWidget {
  const HealthPlanScreen({super.key});

  @override
  State<HealthPlanScreen> createState() => _HealthPlanScreenState();
}

class _HealthPlanScreenState extends State<HealthPlanScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: const CustomAppBar(
        title: 'Health Plans',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Overview
            _buildCurrentPlan(),
            
            const SizedBox(height: 32),
            
            // Goals Section
            const SectionHeader(
              title: 'Your Goals',
              subtitle: 'Track your health objectives',
            ),
            const SizedBox(height: 16),
            _buildGoalsSection(),
            
            const SizedBox(height: 32),
            
            // Recommendations
            const SectionHeader(
              title: 'AI Recommendations',
              subtitle: 'Personalized health suggestions',
            ),
            const SizedBox(height: 16),
            _buildRecommendations(),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlan() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.planGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Health Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Weight Management & Fitness',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPlanStat('Duration', '4 weeks'),
              ),
              Expanded(
                child: _buildPlanStat('Progress', '65%'),
              ),
              Expanded(
                child: _buildPlanStat('Next Goal', '2 days'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      children: [
        StatCard(
          title: 'Daily Steps',
          value: '10,000 steps',
          subtitle: 'Current: 7,500 steps (75%)',
          icon: Icons.directions_walk,
          iconColor: AppTheme.primaryGreen,
          trailing: const Icon(Icons.trending_up, color: AppTheme.successGreen),
        ),
        const SizedBox(height: 12),
        StatCard(
          title: 'Water Intake',
          value: '2.0 L',
          subtitle: 'Current: 1.2 L (60%)',
          icon: Icons.water_drop,
          iconColor: AppTheme.secondaryBlue,
          trailing: const Icon(Icons.trending_down, color: AppTheme.warningYellow),
        ),
        const SizedBox(height: 12),
        StatCard(
          title: 'Calorie Target',
          value: '2,000 kcal',
          subtitle: 'Current: 1,850 kcal (93%)',
          icon: Icons.local_fire_department,
          iconColor: AppTheme.accentOrange,
          trailing: const Icon(Icons.trending_up, color: AppTheme.successGreen),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      children: [
        _buildRecommendationCard(
          'Increase Water Intake',
          'You\'re 40% below your daily water goal. Try setting hourly reminders.',
          Icons.water_drop,
          AppTheme.secondaryBlue,
          'Set Reminder',
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          'Add Evening Walk',
          'A 15-minute evening walk can help you reach your step goal.',
          Icons.directions_walk,
          AppTheme.primaryGreen,
          'Plan Walk',
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          'Balanced Nutrition',
          'Consider adding more protein to your meals for better muscle recovery.',
          Icons.restaurant,
          AppTheme.accentOrange,
          'View Tips',
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String actionText,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textMedium,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ModernButton(
              text: actionText,
              type: ModernButtonType.outline,
              onPressed: () {
                // Handle recommendation action
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ModernButton(
          text: 'Generate New Plan',
          icon: Icons.auto_awesome,
          type: ModernButtonType.primary,
          isFullWidth: true,
          isLoading: _isLoading,
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            // Simulate API call
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _isLoading = false;
              });
              _showPlanGeneratedDialog();
            });
          },
        ),
        const SizedBox(height: 12),
        ModernButton(
          text: 'View Progress History',
          icon: Icons.analytics,
          type: ModernButtonType.secondary,
          isFullWidth: true,
          onPressed: () {
            // Navigate to progress history
          },
        ),
      ],
    );
  }

  void _showPlanGeneratedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Plan Generated!'),
          ],
        ),
        content: const Text(
          'Your new personalized health plan has been created based on your current progress and goals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Plan'),
          ),
        ],
      ),
    );
  }
}