package models

import (
	"time"

	"gorm.io/gorm"
)

// Step represents a user's daily step count.
type Step struct {
	ID         uint           `gorm:"primaryKey" json:"id"`
	UserID     uint           `json:"user_id"`
	Date       time.Time      `gorm:"type:date" json:"date"`
	StepsCount int            `json:"steps_count"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
}

// StepResponse represents the structure of a step entry for API responses.
type StepResponse struct {
	ID         uint      `json:"id"`
	UserID     uint      `json:"user_id"`
	Date       time.Time `json:"date"`
	StepsCount int       `json:"steps_count"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// StepModel provides methods for interacting with the steps table.
type StepModel struct {
	DB *gorm.DB
}

// CreateStep creates a new step entry in the database.
func (m *StepModel) CreateStep(step *Step) error {
	return m.DB.Create(step).Error
}

// GetStepByUserIDAndDate retrieves a step entry for a specific user and date.
func (m *StepModel) GetStepByUserIDAndDate(userID uint, date time.Time) (*Step, error) {
	var step Step
	err := m.DB.Where("user_id = ? AND date = ?", userID, date.Format("2006-01-02")).First(&step).Error
	if err != nil {
		return nil, err
	}
	return &step, nil
}

// UpdateStep updates an existing step entry in the database.
func (m *StepModel) UpdateStep(step *Step) error {
	return m.DB.Save(step).Error
}

// GetStepsByUserID retrieves all step entries for a specific user.
func (m *StepModel) GetStepsByUserID(userID uint) ([]Step, error) {
	var steps []Step
	err := m.DB.Where("user_id = ?", userID).Order("date desc").Find(&steps).Error
	if err != nil {
		return nil, err
	}
	return steps, nil
}
