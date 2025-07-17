import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:health_pal_frontend/widgets/custom_app_bar.dart';
import 'package:health_pal_frontend/widgets/loading_overlay.dart';
import 'package:health_pal_frontend/services/food_photo_service.dart';
import 'package:health_pal_frontend/services/food_analysis_service.dart';
import 'package:health_pal_frontend/services/nutrition_service.dart';
import 'package:health_pal_frontend/utils/api_client.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final FoodPhotoService _foodPhotoService = FoodPhotoService(apiClient: ApiClient());
  final FoodAnalysisService _foodAnalysisService = FoodAnalysisService(apiClient: ApiClient());
  final NutritionService _nutritionService = NutritionService(apiClient: ApiClient());

  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingContro