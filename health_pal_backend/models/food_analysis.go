package models

import (
	"time"

	"gorm.io/gorm"
)

// FoodAnalysis represents the model for food analysis results in the database.
type FoodAnalysis struct {
	ID            uint           `gorm:"primaryKey" json:"id"`
	FoodPhotoID   uint           `gorm:"not null" json:"food_photo_id"`
	DetectedItems string         `gorm:"type:text;not null" json:"detected_items"`
	TotalCalories float64        `gorm:"type:decimal(10,2);not null" json:"total_calories"`
	AnalysisDate  time.Time      `json:"analysis_date"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
	FoodPhoto     FoodPhoto      `gorm:"foreignKey:FoodPhotoID" json:"-"` // Belongs To FoodPhoto
}

// FoodAnalysisResponse represents the response structure for food analysis.
type FoodAnalysisResponse struct {
	ID            uint      `json:"id"`
	FoodPhotoID   uint      `json:"food_photo_id"`
	DetectedItems string    `json:"detected_items"`
	TotalCalories float64   `json:"total_calories"`
	AnalysisDate  time.Time `json:"analysis_date"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

// FoodAnalysisModel provides methods for interacting with the food_analyses table.
type FoodAnalysisModel struct {
	DB *gorm.DB
}

// CreateFoodAnalysis creates a new food analysis entry in the database.
func (m *FoodAnalysisModel) CreateFoodAnalysis(foodAnalysis *FoodAnalysis) error {
	return m.DB.Create(foodAnalysis).Error
}

// GetFoodAnalysisByID retrieves a food analysis entry by its ID.
func (m *FoodAnalysisModel) GetFoodAnalysisByID(id uint) (*FoodAnalysis, error) {
	var foodAnalysis FoodAnalysis
	err := m.DB.First(&foodAnalysis, id).Error
	if err != nil {
		return nil, err
	}
	return &foodAnalysis, nil
}

// GetFoodAnalysesByFoodPhotoID retrieves all food analysis entries for a given food photo ID.
func (m *FoodAnalysisModel) GetFoodAnalysesByFoodPhotoID(foodPhotoID uint) ([]FoodAnalysis, error) {
	var foodAnalyses []FoodAnalysis
	err := m.DB.Where("food_photo_id = ?", foodPhotoID).Order("analysis_date desc").Find(&foodAnalyses).Error
	if err != nil {
		return nil, err
	}
	return foodAnalyses, nil
}

// GetFoodAnalysesByUserID retrieves all food analysis entries for a given user ID.
func (m *FoodAnalysisModel) GetFoodAnalysesByUserID(userID uint) ([]FoodAnalysis, error) {
	var foodAnalyses []FoodAnalysis
	err := m.DB.
		Joins("FoodPhoto").
		Where("FoodPhoto.user_id = ?", userID).
		Order("food_analyses.analysis_date desc").
		Find(&foodAnalyses).Error
	if err != nil {
		return nil, err
	}
	return foodAnalyses, nil
}