package handlers

import (
	"health_pal_backend/models"
	"health_pal_backend/utils"
	"net/http"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// FoodAnalysisHandler struct for handling food analysis related requests
type FoodAnalysisHandler struct {
	FoodAnalysisModel *models.FoodAnalysisModel
	FoodPhotoModel    *models.FoodPhotoModel
}

// AnalyzeFoodPhotoHandler handles the request to analyze a food photo using Gemini API.
// @Summary Analyze a food photo
// @Description Analyzes an uploaded food photo using the Gemini API to extract food items and calorie information.
// @Tags Food Analysis
// @Accept json
// @Produce json
// @Param food_photo_id body int true "ID of the food photo to analyze"
// @Success 201 {object} models.FoodAnalysisResponse "Food photo analyzed successfully"
// @Failure 400 {object} ErrorResponse "Invalid request or food photo not found"
// @Failure 401 {object} ErrorResponse "Unauthorized"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/food-photos/analyze [post]
func (h *FoodAnalysisHandler) AnalyzeFoodPhotoHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var requestBody struct {
		FoodPhotoID uint `json:"food_photo_id"`
	}

	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	foodPhoto, err := h.FoodPhotoModel.GetFoodPhotoByID(requestBody.FoodPhotoID)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Food photo not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve food photo"})
		return
	}

	// Ensure the food photo belongs to the authenticated user
	if foodPhoto.UserID != userID.(uint) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized to analyze this food photo"})
		return
	}

	// Construct the absolute path to the image
	// Assuming images are stored in a relative 'uploads/food_photos' directory
	imagePath := filepath.Join(".", foodPhoto.ImageURL)

	// Call Gemini API to analyze the image
	detectedItems, totalCalories, err := utils.AnalyzeFoodImageWithGemini(imagePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to analyze image with Gemini API: %v", err)})
		return
	}

	foodAnalysis := models.FoodAnalysis{
		FoodPhotoID:   foodPhoto.ID,
		DetectedItems: detectedItems,
		TotalCalories: totalCalories,
		AnalysisDate:  time.Now(),
	}

	if err := h.FoodAnalysisModel.CreateFoodAnalysis(&foodAnalysis); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save food analysis data"})
		return
	}

	c.JSON(http.StatusCreated, models.FoodAnalysisResponse{
		ID:            foodAnalysis.ID,
		FoodPhotoID:   foodAnalysis.FoodPhotoID,
		DetectedItems: foodAnalysis.DetectedItems,
		TotalCalories: foodAnalysis.TotalCalories,
		AnalysisDate:  foodAnalysis.AnalysisDate,
		CreatedAt:     foodAnalysis.CreatedAt,
	})
}

// GetFoodAnalysisHistoryHandler retrieves the history of food analysis for the authenticated user.
// @Summary Get food analysis history
// @Description Retrieves all food analysis results for the authenticated user.
// @Tags Food Analysis
// @Produce json
// @Success 200 {array} models.FoodAnalysisResponse "Food analysis history retrieved successfully"
// @Failure 401 {object} ErrorResponse "Unauthorized"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/food-photos/analysis-history [get]
func (h *FoodAnalysisHandler) GetFoodAnalysisHistoryHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	foodAnalyses, err := h.FoodAnalysisModel.GetFoodAnalysesByUserID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve food analysis history"})
		return
	}

	var response []models.FoodAnalysisResponse
	for _, fa := range foodAnalyses {
		response = append(response, models.FoodAnalysisResponse{
			ID:            fa.ID,
			FoodPhotoID:   fa.FoodPhotoID,
			DetectedItems: fa.DetectedItems,
			TotalCalories: fa.TotalCalories,
			AnalysisDate:  fa.AnalysisDate,
			CreatedAt:     fa.CreatedAt,
		})
	}
	c.JSON(http.StatusOK, response)
}