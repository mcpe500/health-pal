package handlers

import (
	"health_pal_backend/models"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// HPDataHandler struct for handling HP data related requests
type HPDataHandler struct {
	HPHealthDataModel *models.HPHealthDataModel
}

// UploadHPDataHandler handles the upload of health data from the user's phone.
// @Summary Upload HP health data
// @Description Uploads health data collected from the user's phone (e.g., steps, heart rate).
// @Tags HP Data
// @Accept json
// @Produce json
// @Param data body []models.HPHealthData true "Array of health data entries"
// @Success 201 {object} SuccessResponse "Health data uploaded successfully"
// @Failure 400 {object} ErrorResponse "Invalid request body"
// @Failure 401 {object} ErrorResponse "Unauthorized"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/hp-data/upload [post]
func (h *HPDataHandler) UploadHPDataHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var dataEntries []models.HPHealthData
	if err := c.ShouldBindJSON(&dataEntries); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	for _, entry := range dataEntries {
		entry.UserID = userID.(uint)
		if err := h.HPHealthDataModel.CreateHPHealthData(&entry); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save health data entry"})
			return
		}
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Health data uploaded successfully"})
}

// GetHPDataHistoryHandler retrieves historical health data for the authenticated user.
// @Summary Get HP health data history
// @Description Retrieves historical health data for the authenticated user, with optional filters.
// @Tags HP Data
// @Produce json
// @Param data_type query string false "Filter by data type (e.g., 'steps', 'heart_rate')"
// @Param start_date query string false "Filter by start date (YYYY-MM-DD)"
// @Param end_date query string false "Filter by end date (YYYY-MM-DD)"
// @Success 200 {array} models.HPHealthDataResponse "Health data history retrieved successfully"
// @Failure 400 {object} ErrorResponse "Invalid date format"
// @Failure 401 {object} ErrorResponse "Unauthorized"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/hp-data/history [get]
func (h *HPDataHandler) GetHPDataHistoryHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	dataType := c.Query("data_type")
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	var startDate *time.Time
	if startDateStr != "" {
		parsedDate, err := time.Parse("2006-01-02", startDateStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start_date format. Use YYYY-MM-DD"})
			return
		}
		startDate = &parsedDate
	}

	var endDate *time.Time
	if endDateStr != "" {
		parsedDate, err := time.Parse("2006-01-02", endDateStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid end_date format. Use YYYY-MM-DD"})
			return
		}
		endDate = &parsedDate
	}

	data, err := h.HPHealthDataModel.GetHPHealthDataByUserID(userID.(uint), dataType, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve HP health data"})
		return
	}

	var response []models.HPHealthDataResponse
	for _, entry := range data {
		response = append(response, models.HPHealthDataResponse{
			ID:        entry.ID,
			UserID:    entry.UserID,
			DataType:  entry.DataType,
			Value:     entry.Value,
			Unit:      entry.Unit,
			Timestamp: entry.Timestamp,
			CreatedAt: entry.CreatedAt,
		})
	}
	c.JSON(http.StatusOK, response)
}