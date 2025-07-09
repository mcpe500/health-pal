package handlers

import (
	"health_pal_backend/api_types"
	"health_pal_backend/models"
	"health_pal_backend/utils"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// FoodPhotoHandler struct for handling food photo related requests
type FoodPhotoHandler struct {
	FoodPhotoModel *models.FoodPhotoModel
}

// UploadFoodPhotoHandler handles the upload of food photos.
// @Summary Upload a food photo
// @Description Uploads a food photo for the authenticated user.
// @Tags Food Photos
// @Accept multipart/form-data
// @Produce json
// @Param image formData file true "Food photo image file"
// @Param description formData string false "Optional description for the food photo"
// @Param meal_type formData string false "Optional meal type (e.g., breakfast, lunch, dinner)"
// @Success 201 {object} models.FoodPhotoResponse "Food photo uploaded successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid request or file upload error"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/food-photos/upload [post]
func (h *FoodPhotoHandler) UploadFoodPhotoHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Image file is required"})
		return
	}

	uploadDir := filepath.Join(".", "uploads", "food_photos")
	imageURL, err := utils.SaveUploadedFile(file, uploadDir)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save image"})
		return
	}

	description := c.PostForm("description")
	mealType := c.PostForm("meal_type")

	foodPhoto := models.FoodPhoto{
		UserID:   userID.(uint),
		ImageURL: imageURL,
	}

	if description != "" {
		foodPhoto.Description = &description
	}
	if mealType != "" {
		foodPhoto.MealType = &mealType
	}

	if err := h.FoodPhotoModel.CreateFoodPhoto(&foodPhoto); err != nil {
		// If database saving fails, attempt to delete the uploaded file
		os.Remove(filepath.Join(".", imageURL))
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save food photo data"})
		return
	}

	c.JSON(http.StatusCreated, models.FoodPhotoResponse{
		ID:          foodPhoto.ID,
		UserID:      foodPhoto.UserID,
		ImageURL:    foodPhoto.ImageURL,
		Description: foodPhoto.Description,
		MealType:    foodPhoto.MealType,
		CreatedAt:   foodPhoto.CreatedAt,
	})
}

// GetFoodPhotoHistoryHandler retrieves the history of food photos for the authenticated user.
// @Summary Get food photo history
// @Description Retrieves all food photos uploaded by the authenticated user.
// @Tags Food Photos
// @Produce json
// @Success 200 {array} models.FoodPhotoResponse "Food photo history retrieved successfully"
// @Failure 400 {object} api_types.ErrorResponse "Invalid request or file upload error"
// @Failure 401 {object} api_types.ErrorResponse "Unauthorized"
// @Failure 500 {object} api_types.ErrorResponse "Internal server error"
// @Security ApiKeyAuth
// @Router /api/v1/food-photos/history [get]
func (h *FoodPhotoHandler) GetFoodPhotoHistoryHandler(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	foodPhotos, err := h.FoodPhotoModel.GetFoodPhotosByUserID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve food photo history"})
		return
	}

	var response []models.FoodPhotoResponse
	for _, fp := range foodPhotos {
		response = append(response, models.FoodPhotoResponse{
			ID:          fp.ID,
			UserID:      fp.UserID,
			ImageURL:    fp.ImageURL,
			Description: fp.Description,
			MealType:    fp.MealType,
			CreatedAt:   fp.CreatedAt,
		})
	}
	c.JSON(http.StatusOK, response)
}