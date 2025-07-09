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

// ReminderHandler struct for handling reminder related requests
type ReminderHandler struct {
	ReminderModel       *models.ReminderModel
	DailyNutritionModel *models.DailyNutritionModel
	StepModel           *models.StepModel
	HealthPlanModel     *models.HealthPlanModel
}

// ScheduleReminderHandler handles the request to schedule a personalized reminder.
// @Summary Schedule a reminder
// @Description Schedules a personalized reminder based on user data and health goals.
// @Tags Reminders
// @Accept json
// @Produce json
// @Param reminder body object true "Reminder details (e.g., scheduled_time, type)"
// @Success 201 {object} api_types.SuccessResponse "Reminder scheduled successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid request"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/reminders/schedule [post]
func (h *ReminderHandler) ScheduleReminderHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var requestBody struct {
		ScheduledTime string `json:"scheduled_time"` // e.g., "2025-07-08T14:30:00Z"
		Type          string `json:"type"`           // e.g., "morning_checkin", "exercise_reminder", "custom"
		CustomMessage string `json:"custom_message"` // Optional custom message for "custom" type
	}

	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	scheduledTime, err := time.Parse(time.RFC3339, requestBody.ScheduledTime)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid scheduled_time format. Use RFC3339."})
		return
	}

	// Fetch user data for personalized reminder generation
	// For simplicity, fetching latest data. In a real app, might need to fetch data relevant to scheduledTime.
	latestHealthPlan, _ := h.HealthPlanModel.GetLatestHealthPlanByUserID(userID.(uint))
	healthGoals := ""
	healthPlanSummary := ""
	if latestHealthPlan != nil {
		healthGoals = latestHealthPlan.Goal
		healthPlanSummary = latestHealthPlan.PlanDetails // Assuming plan_details contains a summary
	}

	// Fetch recent nutrition data (e.g., for today)
	nutritionSummary, _ := h.DailyNutritionModel.GetDailyNutritionSummaryByUserIDAndDate(userID.(uint), time.Now())
	recentNutrition := "No recent nutrition data."
	if nutritionSummary != nil {
		recentNutrition = fmt.Sprintf("Calories: %.2f, Protein: %.2f, Carbs: %.2f, Fats: %.2f",
			nutritionSummary.TotalCalories, nutritionSummary.TotalProtein, nutritionSummary.TotalCarbohydrates, nutritionSummary.TotalFats)
	}

	// Fetch recent activity data (e.g., for today)
	steps, _ := h.StepModel.GetStepsByUserIDAndDate(userID.(uint), time.Now()) // Assuming GetStepsByUserIDAndDate exists
	recentActivity := "No recent activity data."
	if steps != nil {
		recentActivity = fmt.Sprintf("Steps: %d", steps.StepsCount)
	}

	reminderText := requestBody.CustomMessage
	if requestBody.Type != "custom" {
		// Use Gemini to generate personalized reminder text
		generatedText, err := utils.GenerateReminderTextWithGemini(
			userID.(uint), healthGoals, healthPlanSummary, recentActivity, recentNutrition)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to generate reminder text: %v", err)})
			return
		}
		reminderText = generatedText
	}

	reminder := models.Reminder{
		UserID:        userID.(uint),
		ReminderText:  reminderText,
		ScheduledTime: scheduledTime,
		Status:        "pending", // Initial status
	}

	if err := h.ReminderModel.CreateReminder(&reminder); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to schedule reminder"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Reminder scheduled successfully", "reminder_id": reminder.ID})
}

// GetRemindersHandler retrieves scheduled reminders for the authenticated user.
// @Summary Get reminders
// @Description Retrieves all scheduled and sent reminders for the authenticated user.
// @Tags Reminders
// @Produce json
// @Success 200 {array} models.ReminderResponse "Reminders retrieved successfully"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/reminders [get]
func (h *ReminderHandler) GetRemindersHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	reminders, err := h.ReminderModel.GetRemindersByUserID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve reminders"})
		return
	}

	var response []models.ReminderResponse
	for _, r := range reminders {
		response = append(response, models.ReminderResponse{
			ID:            r.ID,
			UserID:        r.UserID,
			ReminderText:  r.ReminderText,
			ScheduledTime: r.ScheduledTime,
			Status:        r.Status,
			CreatedAt:     r.CreatedAt,
			SentAt:        r.SentAt,
		})
	}
	c.JSON(http.StatusOK, response)
}