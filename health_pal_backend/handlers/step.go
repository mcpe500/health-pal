package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"health_pal_backend/api_types"
	"health_pal_backend/models"
)

// RecordStepsRequest represents the request body for recording steps.
type RecordStepsRequest struct {
	Date      string `json:"date" binding:"required"`
	StepsCount int    `json:"steps_count" binding:"required,min=0"`
}

// RecordStepsHandler handles the recording of daily steps for a user.
// @Summary Record daily steps
// @Description Records or updates the daily step count for the authenticated user.
// @Tags Steps
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param steps body RecordStepsRequest true "Steps data"
// @Success 200 {object} api_types.SuccessResponse "Steps recorded successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid request payload"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Router /api/v1/steps [post]
func RecordStepsHandler(stepModel *models.StepModel) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			return
		}

		var req RecordStepsRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		parsedDate, err := time.Parse("2006-01-02", req.Date)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD"})
			return
		}

		// Check if a step entry already exists for the user and date
		step, err := stepModel.GetStepByUserIDAndDate(userID.(uint), parsedDate)
		if err != nil && err != gorm.ErrRecordNotFound {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check existing steps"})
			return
		}

		if step != nil {
			// Update existing entry
			step.StepsCount = req.StepsCount
			err = stepModel.UpdateStep(step)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update steps"})
				return
			}
			c.JSON(http.StatusOK, gin.H{"message": "Steps updated successfully"})
			return
		}

		// Create new entry
		newStep := models.Step{
			UserID:     userID.(uint),
			Date:       parsedDate,
			StepsCount: req.StepsCount,
		}
		err = stepModel.CreateStep(&newStep)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record steps"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Steps recorded successfully"})
	}
}

// GetStepsHistoryHandler retrieves the step history for the authenticated user.
// @Summary Get step history
// @Description Retrieves all recorded step counts for the authenticated user.
// @Tags Steps
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} models.StepResponse "List of step entries"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Router /api/v1/steps/history [get]
func GetStepsHistoryHandler(stepModel *models.StepModel) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			return
		}

		steps, err := stepModel.GetStepsByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve step history"})
			return
		}

		c.JSON(http.StatusOK, steps)
	}
}
