package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"health_pal_backend/api_types"
	"health_pal_backend/models"
)

// RecordSittingTimeRequest represents the request body for recording sitting time.
type RecordSittingTimeRequest struct {
	Date            string `json:"date" binding:"required"`
	DurationMinutes int    `json:"duration_minutes" binding:"required,min=0"`
}

// RecordSittingTimeHandler handles the recording of daily sitting time for a user.
// @Summary Record daily sitting time
// @Description Records or updates the daily sitting time in minutes for the authenticated user.
// @Tags SittingTime
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param sittingTime body RecordSittingTimeRequest true "Sitting time data"
// @Success 200 {object} api_types.SuccessResponse "Sitting time recorded successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid request payload"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Router /api/v1/sitting-times [post]
func RecordSittingTimeHandler(sittingTimeModel *models.SittingTimeModel) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			return
		}

		var req RecordSittingTimeRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		parsedDate, err := time.Parse("2006-01-02", req.Date)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD"})
			return
		}

		// Check if a sitting time entry already exists for the user and date
		sittingTime, err := sittingTimeModel.GetSittingTimeByUserIDAndDate(userID.(uint), parsedDate)
		if err != nil && err != gorm.ErrRecordNotFound {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check existing sitting time"})
			return
		}

		if sittingTime != nil {
			// Update existing entry
			sittingTime.DurationMinutes = req.DurationMinutes
			err = sittingTimeModel.UpdateSittingTime(sittingTime)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update sitting time"})
				return
			}
			c.JSON(http.StatusOK, gin.H{"message": "Sitting time updated successfully"})
			return
		}

		// Create new entry
		newSittingTime := models.SittingTime{
			UserID:          userID.(uint),
			Date:            parsedDate,
			DurationMinutes: req.DurationMinutes,
		}
		err = sittingTimeModel.CreateSittingTime(&newSittingTime)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record sitting time"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Sitting time recorded successfully"})
	}
}

// GetSittingTimeHistoryHandler retrieves the sitting time history for the authenticated user.
// @Summary Get sitting time history
// @Description Retrieves all recorded sitting times in minutes for the authenticated user.
// @Tags SittingTime
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} models.SittingTimeResponse "List of sitting time entries"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Router /api/v1/sitting-times/history [get]
func GetSittingTimeHistoryHandler(sittingTimeModel *models.SittingTimeModel) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			return
		}

		sittingTimes, err := sittingTimeModel.GetSittingTimesByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve sitting time history"})
			return
		}

		c.JSON(http.StatusOK, sittingTimes)
	}
}
