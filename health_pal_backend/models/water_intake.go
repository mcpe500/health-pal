package models

import (
	"time"

	"gorm.io/gorm"
)

// WaterIntake represents a user's daily water intake.
type WaterIntake struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `json:"user_id"`
	Date      time.Time      `gorm:"type:date" json:"date"`
	AmountML  int            `json:"amount_ml"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
}

// WaterIntakeResponse represents the structure of a water intake entry for API responses.
type WaterIntakeResponse struct {
	ID        uint      `json:"id"`
	UserID    uint      `json:"user_id"`
	Date      time.Time `json:"date"`
	AmountML  int       `json:"amount_ml"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// WaterIntakeModel provides methods for interacting with the water_intakes table.
type WaterIntakeModel struct {
	DB *gorm.DB
}

// FoodPhotoModel provides methods for interacting with the food_photos table.
type FoodPhotoModel struct {
	DB *gorm.DB
}

// CreateWaterIntake creates a new water intake entry in the database.
func (m *WaterIntakeModel) CreateWaterIntake(waterIntake *WaterIntake) error {
	return m.DB.Create(waterIntake).Error
}

// GetWaterIntakeByUserIDAndDate retrieves a water intake entry for a specific user and date.
func (m *WaterIntakeModel) GetWaterIntakeByUserIDAndDate(userID uint, date time.Time) (*WaterIntake, error) {
	var waterIntake WaterIntake
	err := m.DB.Where("user_id = ? AND date = ?", userID, date.Format("2006-01-02")).First(&waterIntake).Error
	if err != nil {
		return nil, err
	}
	return &waterIntake, nil
}

// UpdateWaterIntake updates an existing water intake entry in the database.
func (m *WaterIntakeModel) UpdateWaterIntake(waterIntake *WaterIntake) error {
	return m.DB.Save(waterIntake).Error
}

// GetWaterIntakesByUserID retrieves all water intake entries for a specific user.
func (m *WaterIntakeModel) GetWaterIntakesByUserID(userID uint) ([]WaterIntake, error) {
	var waterIntakes []WaterIntake
	err := m.DB.Where("user_id = ?", userID).Order("date desc").Find(&waterIntakes).Error
	if err != nil {
		return nil, err
	}
	return waterIntakes, nil
}
}
