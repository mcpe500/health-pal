package models

import (
	"time"

	"gorm.io/gorm"
)

// SittingTime represents a user's daily sitting time.
type SittingTime struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	UserID          uint           `json:"user_id"`
	Date            time.Time      `gorm:"type:date" json:"date"`
	DurationMinutes int            `json:"duration_minutes"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
}

// SittingTimeResponse represents the structure of a sitting time entry for API responses.
type SittingTimeResponse struct {
	ID              uint      `json:"id"`
	UserID          uint      `json:"user_id"`
	Date            time.Time `json:"date"`
	DurationMinutes int       `json:"duration_minutes"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

// SittingTimeModel provides methods for interacting with the sitting_times table.
type SittingTimeModel struct {
	DB *gorm.DB
}

// CreateSittingTime creates a new sitting time entry in the database.
func (m *SittingTimeModel) CreateSittingTime(sittingTime *SittingTime) error {
	return m.DB.Create(sittingTime).Error
}

// GetSittingTimeByUserIDAndDate retrieves a sitting time entry for a specific user and date.
func (m *SittingTimeModel) GetSittingTimeByUserIDAndDate(userID uint, date time.Time) (*SittingTime, error) {
	var sittingTime SittingTime
	err := m.DB.Where("user_id = ? AND date = ?", userID, date.Format("2006-01-02")).First(&sittingTime).Error
	if err != nil {
		return nil, err
	}
	return &sittingTime, nil
}

// UpdateSittingTime updates an existing sitting time entry in the database.
func (m *SittingTimeModel) UpdateSittingTime(sittingTime *SittingTime) error {
	return m.DB.Save(sittingTime).Error
}

// GetSittingTimesByUserID retrieves all sitting time entries for a specific user.
func (m *SittingTimeModel) GetSittingTimesByUserID(userID uint) ([]SittingTime, error) {
	var sittingTimes []SittingTime
	err := m.DB.Where("user_id = ?", userID).Order("date desc").Find(&sittingTimes).Error
	if err != nil {
		return nil, err
	}
	return sittingTimes, nil
}
