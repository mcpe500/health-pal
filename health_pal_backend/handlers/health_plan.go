package handlers

import (
	"fmt"
	"health_pal_backend/api_types"
	"health_pal_backend/models"
	"health_pal_backend/utils"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// HealthPlanHandler struct for handling health plan related requests
type HealthPlanHandler struct {
	HealthPlanModel     *models.HealthPlanModel
	DailyNutritionModel *models.DailyNutritionModel
	StepModel           *models.StepModel // Assuming you have a StepModel to fetch activity data
}

// GenerateHealthPlanHandler handles the request to generate a personalized health plan.
// @Summary Generate a health plan
// @Description Generates a personalized health plan based on user's goals, nutrition, and activity data using Gemini API.
// @Tags Health Plan
// @Accept json
// @Produce json
// @Param goals body string true "User's health goals (e.g., 'Weight Loss', 'Muscle Gain')"
// @Success 201 {object} models.HealthPlanResponse "Health plan generated successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid request"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/health-plan/generate [post]
func (h *HealthPlanHandler) GenerateHealthPlanHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var requestBody struct {
		Goals string `json:"goals"`
	}

	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Fetch recent nutrition data (e.g., last 7 days summary)
	nutritionSummaries, err := h.DailyNutritionModel.GetDailyNutritionSummariesByUserID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch nutrition data"})
		return
	}
	nutritionData := formatNutritionData(nutritionSummaries) // Helper to format data

	// Fetch recent activity data (e.g., steps from last 7 days)
	stepHistory, err := h.StepModel.GetStepsByUserID(userID.(uint)) // Assuming GetStepsByUserID exists
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch activity data"})
		return
	}
	activityData := formatActivityData(stepHistory) // Helper to format data

	// Generate health plan using Gemini
	planDetails, err := utils.GenerateHealthPlanWithGemini(userID.(uint), requestBody.Goals, nutritionData, activityData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to generate health plan: %v", err)})
		return
	}

	healthPlan := models.HealthPlan{
		UserID:        userID.(uint),
		Goal:          requestBody.Goals,
		PlanDetails:   planDetails,
		GeneratedDate: time.Now(),
	}

	if err := h.HealthPlanModel.CreateHealthPlan(&healthPlan); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save health plan"})
		return
	}

	c.JSON(http.StatusCreated, models.HealthPlanResponse{
		ID:            healthPlan.ID,
		UserID:        healthPlan.UserID,
		Goal:          healthPlan.Goal,
		PlanDetails:   healthPlan.PlanDetails,
		GeneratedDate: healthPlan.GeneratedDate,
		CreatedAt:     healthPlan.CreatedAt,
	})
}

// GetHealthPlanHandler retrieves the latest health plan for the authenticated user.
// @Summary Get health plan
// @Description Retrieves the latest personalized health plan for the authenticated user.
// @Tags Health Plan
// @Produce json
// @Success 200 {object} models.HealthPlanResponse "Health plan retrieved successfully"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 404 {object} api_types.ErrorResponse "Health plan not found"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/health-plan [get]
func (h *HealthPlanHandler) GetHealthPlanHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	healthPlan, err := h.HealthPlanModel.GetLatestHealthPlanByUserID(userID.(uint))
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Health plan not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve health plan"})
		return
	}

	c.JSON(http.StatusOK, models.HealthPlanResponse{
		ID:            healthPlan.ID,
		UserID:        healthPlan.UserID,
		Goal:          healthPlan.Goal,
		PlanDetails:   healthPlan.PlanDetails,
		GeneratedDate: healthPlan.GeneratedDate,
		CreatedAt:     healthPlan.CreatedAt,
	})
}

// Helper function to format nutrition data for Gemini prompt
func formatNutritionData(summaries []models.DailyNutritionSummary) string {
	if len(summaries) == 0 {
		return "No recent nutrition data available."
	}
	var sb strings.Builder
	sb.WriteString("Recent Nutrition Data:\n")
	for _, s := range summaries {
		sb.WriteString(fmt.Sprintf("  Date: %s, Calories: %.2f, Protein: %.2f, Carbs: %.2f, Fats: %.2f\n",
			s.RecordDate.Format("2006-01-02"), s.TotalCalories, s.TotalProtein, s.TotalCarbohydrates, s.TotalFats))
	}
	return sb.String()
}

// Helper function to format activity data for Gemini prompt
func formatActivityData(steps []models.Step) string { // Assuming models.Step struct and GetStepsByUserID
	if len(steps) == 0 {
		return "No recent activity data available."
	}
	var sb strings.Builder
	sb.WriteString("Recent Activity Data (Steps):\n")
	for _, s := range steps {
		sb.WriteString(fmt.Sprintf("  Date: %s, Steps: %d\n", s.Date, s.StepsCount))
	}
	return sb.String()
}