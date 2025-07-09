package handlers

import (
	"health_pal_backend/api_types"
	"health_pal_backend/models"
	"health_pal_backend/utils"
	"net/http"
	"time"
	"encoding/json" // Added for JSON handling

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// NutritionHandler struct for handling nutrition related requests
type NutritionHandler struct {
	DailyNutritionModel *models.DailyNutritionModel
}

// GetDailyNutritionSummaryHandler retrieves the daily nutrition summary for the authenticated user.
// @Summary Get daily nutrition summary
// @Description Retrieves the aggregated daily nutrition data for the authenticated user for a given date.
// @Tags Nutrition
// @Produce json
// @Param date query string true "Date in YYYY-MM-DD format"
// @Success 200 {object} models.DailyNutritionSummaryResponse "Daily nutrition summary retrieved successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid date format"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 404 {object} api_types.ErrorResponse "Nutrition summary not found for the given date"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/nutrition/daily-summary [get]
func (h *NutritionHandler) GetDailyNutritionSummaryHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	dateStr := c.Query("date")
	if dateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Date parameter is required"})
		return
	}

	recordDate, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD"})
		return
	}

	summary, err := h.DailyNutritionModel.GetDailyNutritionSummaryByUserIDAndDate(userID.(uint), recordDate)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Nutrition summary not found for the given date"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve daily nutrition summary"})
		return
	}

	response := models.DailyNutritionSummaryResponse{
		ID:                 summary.ID,
		UserID:             summary.UserID,
		RecordDate:         summary.RecordDate,
		TotalCalories:      summary.TotalCalories,
		TotalProtein:       summary.TotalProtein,
		TotalCarbohydrates: summary.TotalCarbohydrates,
		TotalFats:          summary.TotalFats,
		MicronutrientsJSON: summary.MicronutrientsJSON,
		CreatedAt:          summary.CreatedAt,
	}
	c.JSON(http.StatusOK, response)
}

// ManualNutritionEntryHandler allows users to manually log nutrition data.
// @Summary Manually log nutrition data
// @Description Allows users to manually input nutrition data for a specific date.
// @Tags Nutrition
// @Accept json
// @Produce json
// @Param nutrition body models.DailyNutritionSummary true "Nutrition data to log"
// @Success 201 {object} api_types.SuccessResponse "Nutrition data logged successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid request body"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/nutrition/manual-entry [post]
func (h *NutritionHandler) ManualNutritionEntryHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var requestBody models.DailyNutritionSummary
	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	requestBody.UserID = userID.(uint)
	requestBody.RecordDate = requestBody.RecordDate.Local().Truncate(24 * time.Hour) // Ensure date is truncated to start of day

	// Validate micronutrients_json if provided
	if requestBody.MicronutrientsJSON != "" {
		var testMap map[string]interface{}
		if err := json.Unmarshal([]byte(requestBody.MicronutrientsJSON), &testMap); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid micronutrients_json format"})
			return
		}
	}

	if err := h.DailyNutritionModel.UpsertDailyNutritionSummary(&requestBody); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save nutrition data"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Nutrition data logged successfully"})
}