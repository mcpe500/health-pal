package models

import (
	"time"

	"gorm.io/gorm"
)

// HPHealthData represents health data collected from the user's phone.
type HPHealthData struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `gorm:"not null" json:"user_id"`
	DataType  string         `gorm:"size:100;not null" json:"data_type"` // e.g., "steps", "heart_rate", "sleep"
	Value     float64        `gorm:"type:decimal(10,2);not null" json:"value"`
	Unit      string         `gorm:"size:50;not null" json:"unit"` // e.g., "count", "bpm", "hours"
	Timestamp time.Time      `gorm:"not null" json:"timestamp"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty" swaggertype:"string"`
	User      User           `gorm:"foreignKey:UserID" json:"-"` // Belongs To User
}

// HPHealthDataResponse represents the response structure for HP health data.
type HPHealthDataResponse struct {
	ID        uint      `json:"id"`
	UserID    uint      `json:"user_id"`
	DataType  string    `json:"data_type"`
	Value     float64   `json:"value"`
	Unit      string    `json:"unit"`
	Timestamp time.Time `json:"timestamp"`
	CreatedAt time.Time `json:"created_at"`
}

// HPHealthDataModel provides methods for interacting with the hp_health_data table.
type HPHealthDataModel struct {
	DB *gorm.DB
}

// CreateHPHealthData creates a new HP health data entry in the database.
func (m *HPHealthDataModel) CreateHPHealthData(data *HPHealthData) error {
	return m.DB.Create(data).Error
}

// GetHPHealthDataByUserID retrieves HP health data for a given user ID, optionally filtered by data type and date range.
func (m *HPHealthDataModel) GetHPHealthDataByUserID(userID uint, dataType string, startDate, endDate *time.Time) ([]HPHealthData, error) {
	var data []HPHealthData
	query := m.DB.Where("user_id = ?", userID)

	if dataType != "" {
		query = query.Where("data_type = ?", dataType)
	}
	if startDate != nil {
		query = query.Where("timestamp >= ?", startDate)
	}
	if endDate != nil {
		query = query.Where("timestamp <= ?", endDate)
	}

	err := query.Order("timestamp desc").Find(&data).Error
	if err != nil {
		return nil, err
	}
	return data, nil
}