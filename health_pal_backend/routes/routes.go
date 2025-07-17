// Package routes defines and sets up all HTTP routes for the backend application.
package routes

import (
	"fmt" // Added for fmt.Sprintf
	"net/http" // Added for http.StatusOK, http.StatusInternalServerError
	"time" // Added for time.Now()

	"github.com/gin-gonic/gin"
	"health_pal_backend/handlers"
	"health_pal_backend/middleware"
)

// SetupRoutes initializes and registers all API routes with the Gin router.
// It takes the Gin router instance and handler dependencies as arguments,
// including authHandler, deletionHandler, stepHandler, sittingTimeHandler,
// waterIntakeHandler, foodPhotoHandler, and foodAnalysisHandler.
func SetupRoutes(router *gin.Engine, jwtSecret []byte, authHandler *handlers.AuthHandler, deletionHandler *handlers.DeletionHandler, stepHandler *handlers.StepHandler, sittingTimeHandler *handlers.SittingTimeHandler, waterIntakeHandler *handlers.WaterIntakeHandler, foodPhotoHandler *handlers.FoodPhotoHandler, foodAnalysisHandler *handlers.FoodAnalysisHandler, nutritionHandler *handlers.NutritionHandler, healthPlanHandler *handlers.HealthPlanHandler, reminderHandler *handlers.ReminderHandler, hpDataHandler *handlers.HPDataHandler) {
	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "healthy",
			"message": "Health Pal Backend is running",
			"timestamp": fmt.Sprintf("%v", time.Now()),
		})
	})

	// Public routes
	router.POST("/auth/google-login", authHandler.GoogleLoginHandler)

	// Account Deletion Web Routes
	router.GET("/delete-account", deletionHandler.ShowDeleteAccountForm)
	router.POST("/delete-account", deletionHandler.RequestDeleteAccountOTPWeb)
	router.GET("/delete-account/verify-otp", deletionHandler.ShowVerifyOTPForm)
	router.POST("/delete-account/verify-otp", deletionHandler.VerifyDeleteAccountOTPWeb)

	// API Version 1 Group
	apiV1 := router.Group("/api/v1")
	{
		// Protected routes (require JWT authentication)
		protected := apiV1.Group("/") // Group for protected API routes under /api/v1
		protected.Use(middleware.AuthMiddleware(jwtSecret))
		{
			protected.GET("/profile", func(c *gin.Context) {
				userID, exists := c.Get("userID")
				if !exists {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "User ID not found in context"})
					return
				}
				userEmail, exists := c.Get("userEmail")
				if !exists {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "User email not found in context"})
					return
				}
				c.JSON(http.StatusOK, gin.H{
					"message": fmt.Sprintf("Welcome, User %v (%v)! This is a protected route.", userID, userEmail),
				})
			})
			// Account Deletion API Routes
			protected.POST("/delete-account/request-otp", deletionHandler.RequestDeleteAccountOTPAPI)
			protected.POST("/delete-account/verify-otp", deletionHandler.VerifyDeleteAccountOTPAPI)

			// Step Tracking API Routes
			protected.POST("/steps", stepHandler.RecordStepsHandler)
			protected.GET("/steps/history", stepHandler.GetStepsHistoryHandler)

			// Sitting Time Tracking API Routes
			protected.POST("/sitting-times", sittingTimeHandler.RecordSittingTimeHandler)
			protected.GET("/sitting-times/history", sittingTimeHandler.GetSittingTimeHistoryHandler)

			// Water Intake Tracking API Routes
			protected.POST("/water-intakes", waterIntakeHandler.RecordWaterIntakeHandler)
			protected.GET("/water-intakes/history", waterIntakeHandler.GetWaterIntakeHistoryHandler)

			// Food Photo API Routes
			protected.POST("/food-photos/upload", foodPhotoHandler.UploadFoodPhotoHandler)
			protected.GET("/food-photos/history", foodPhotoHandler.GetFoodPhotoHistoryHandler)

			// Food Analysis API Routes
			protected.POST("/food-photos/analyze", foodAnalysisHandler.AnalyzeFoodPhotoHandler)
			protected.GET("/food-photos/analysis-history", foodAnalysisHandler.GetFoodAnalysisHistoryHandler)

			// Nutrition Tracking API Routes
			protected.GET("/nutrition/daily-summary", nutritionHandler.GetDailyNutritionSummaryHandler)
			protected.POST("/nutrition/manual-entry", nutritionHandler.ManualNutritionEntryHandler)

			// Health Plan API Routes
			protected.POST("/health-plan/generate", healthPlanHandler.GenerateHealthPlanHandler)
			protected.GET("/health-plan", healthPlanHandler.GetHealthPlanHandler)

			// Reminders API Routes
			protected.POST("/reminders/schedule", reminderHandler.ScheduleReminderHandler)
			protected.GET("/reminders", reminderHandler.GetRemindersHandler)

			// HP Data Collection API Routes
			protected.POST("/hp-data/upload", hpDataHandler.UploadHPDataHandler)
			protected.GET("/hp-data/history", hpDataHandler.GetHPDataHistoryHandler)
		}
	}
}