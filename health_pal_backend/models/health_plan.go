package models

import (
	"time"

	"gorm.io/gorm"
)

// HealthPlan represents a personalized health plan generated for a user.
type HealthPlan struct {
	ID            uint           `gorm:"primaryKey" json:"id"`
	UserID        uint           `gorm:"not null" json:"user_id"`
	Goal          string         `gorm:"size:255;not null" json:"goal"`
	PlanDetails   string         `gorm:"type:text;not null" json:"plan_details"` // JSON representation of the plan
	GeneratedDate time.Time      `json:"generated_date"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
	User          User           `gorm:"foreignKey:UserID" json:"-"` // Belongs To User
}

// HealthPlanResponse represents the response structure for a health plan.
type HealthPlanResponse struct {
	ID            uint      `json:"id"`
	UserID        uint      `json:"user_id"`
	Goal          string    `json:"goal"`
	PlanDetails   string    `json:"plan_details"`
	GeneratedDate time.Time `json:"generated_date"`
	CreatedAt     time.Time `json:"created_at"`
}

// HealthPlanModel provides methods for interacting with the health_plans table.
type HealthPlanModel struct {
	DB *gorm.DB
}

// CreateHealthPlan creates a new health plan entry in the database.
func (m *HealthPlanModel) CreateHealthPlan(healthPlan *HealthPlan) error {
	return m.DB.Create(healthPlan).Error
}

// GetLatestHealthPlanByUserID retrieves the latest health plan for a given user ID.
func (m *HealthPlanModel) GetLatestHealthPlanByUserID(userID uint) (*HealthPlan, error) {
	var healthPlan HealthPlan
	err := m.DB.Where("user_id = ?", userID).Order("generated_date desc").First(&healthPlan).Error
	if err != nil {
		return nil, err
	}
	return &healthPlan, nil
}

// UpdateHealthPlan updates an existing health plan entry in the database.
func (m *HealthPlanModel) UpdateHealthPlan(healthPlan *HealthPlan) error {
	return m.DB.Save(healthPlan).Error
}

// DeleteHealthPlan soft deletes a health plan entry by its ID.
func (m *HealthPlanModel) DeleteHealthPlan(id uint) error {
	return m.DB.Delete(&HealthPlan{}, id).Error
}