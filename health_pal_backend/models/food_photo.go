package models

import (
	"time"

	"gorm.io/gorm"
)

// FoodPhoto represents the model for a food photo entry in the database.
type FoodPhoto struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	UserID      uint           `json:"user_id"`
	ImageURL    string         `gorm:"size:255;not null" json:"image_url"`
	Description *string        `gorm:"type:text" json:"description,omitempty"`
	MealType    *string        `gorm:"size:50" json:"meal_type,omitempty"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
	User        User           `gorm:"foreignKey:UserID" json:"-"` // Belongs To User
}

// FoodPhotoResponse represents the response structure for a food photo.
type FoodPhotoResponse struct {
	ID          uint      `json:"id"`
	UserID      uint      `json:"user_id"`
	ImageURL    string    `json:"image_url"`
	Description *string   `json:"description,omitempty"`
	MealType    *string   `json:"meal_type,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

// FoodPhotoModel provides methods for interacting with the food_photos table.
type FoodPhotoModel struct {
	DB *gorm.DB
}

// CreateFoodPhoto creates a new food photo entry in the database.
func (m *FoodPhotoModel) CreateFoodPhoto(foodPhoto *FoodPhoto) error {
	return m.DB.Create(foodPhoto).Error
}

// GetFoodPhotoByID retrieves a food photo by its ID.
func (m *FoodPhotoModel) GetFoodPhotoByID(id uint) (*FoodPhoto, error) {
	var foodPhoto FoodPhoto
	err := m.DB.First(&foodPhoto, id).Error
	if err != nil {
		return nil, err
	}
	return &foodPhoto, nil
}

// GetFoodPhotosByUserID retrieves all food photos for a given user ID.
func (m *FoodPhotoModel) GetFoodPhotosByUserID(userID uint) ([]FoodPhoto, error) {
	var foodPhotos []FoodPhoto
	err := m.DB.Where("user_id = ?", userID).Order("created_at desc").Find(&foodPhotos).Error
	if err != nil {
		return nil, err
	}
	return foodPhotos, nil
}

// UpdateFoodPhoto updates an existing food photo entry in the database.
func (m *FoodPhotoModel) UpdateFoodPhoto(foodPhoto *FoodPhoto) error {
	return m.DB.Save(foodPhoto).Error
}

// DeleteFoodPhoto soft deletes a food photo entry by its ID.
func (m *FoodPhotoModel) DeleteFoodPhoto(id uint) error {
	return m.DB.Delete(&FoodPhoto{}, id).Error
}