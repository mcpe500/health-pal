package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"health_pal_backend/models"
)

// RecordWaterIntakeRequest represents the request body for recording water intake.
type RecordWaterIntakeRequest struct {
	Date     string `json:"date" binding:"required"`
	AmountML int    `json:"amount_ml" binding:"required,min=0"`
}

// RecordWaterIntakeHandler handles the recording of daily water intake for a user.
// @Summary Record daily water intake
// @Description Records or updates the daily water intake in milliliters for the authenticated user.
// @Tags WaterIntake
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param waterIntake body RecordWaterIntakeRequest true "Water intake data"
// @Success 200 {object} models.WaterIntakeResponse "Water intake recorded successfully"
// @Failure 400 {object} map[string]interface{} "error: Invalid request payload"
// @Failure 401 {object} map[string]interface{} "error: Unauthorized"
// @Failure 500 {object} map[string]interface{} "error: Internal server error"
// @Router /api/v1/water-intakes [post]
func RecordWaterIntakeHandler(waterIntakeModel *models.WaterIntakeModel) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			return
		}

		var req RecordWaterIntakeRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		parsedDate, err := time.Parse("2006-01-02", req.Date)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD"})
			return
		}

		// Check if a water intake entry already exists for the user and date
		waterIntake, err := waterIntakeModel.GetWaterIntakeByUserIDAndDate(userID.(uint), parsedDate)
		if err != nil && err != gorm.ErrRecordNotFound {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check existing water intake"})
			return
		}

		if waterIntake != nil {
			// Update existing entry
			waterIntake.AmountML = req.AmountML
			err = waterIntakeModel.UpdateWaterIntake(waterIntake)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update water intake"})
				return
			}
			c.JSON(http.StatusOK, gin.H{"message": "Water intake updated successfully"})
			return
		}

		// Create new entry
		newWaterIntake := models.WaterIntake{
			UserID:   userID.(uint),
			Date:     parsedDate,
			AmountML: req.AmountML,
		}
		err = waterIntakeModel.CreateWaterIntake(&newWaterIntake)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record water intake"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Water intake recorded successfully"})
	}
}

// GetWaterIntakeHistoryHandler retrieves the water intake history for the authenticated user.
// @Summary Get water intake history
// @Description Retrieves all recorded water intake in milliliters for the authenticated user.
// @Tags WaterIntake
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} models.WaterIntakeResponse "List of water intake entries"
// @Failure 401 {object} map[string]interface{} "error: Unauthorized"
// @Failure 500 {object} map[string]interface{} "error: Internal server error"
// @Router /api/v1/water-intakes/history [get]
func GetWaterIntakeHistoryHandler(waterIntakeModel *models.WaterIntakeModel) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			return
		}

		waterIntakes, err := waterIntakeModel.GetWaterIntakesByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve water intake history"})
			return
		}

		c.JSON(http.StatusOK, waterIntakes)
	}
}
