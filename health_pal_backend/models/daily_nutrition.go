package models

import (
	"time"

	"health_pal_backend/utils"
	"gorm.io/gorm"
)

// DailyNutritionSummary represents the aggregated daily nutrition data for a user.
type DailyNutritionSummary struct {
	ID                 uint           `gorm:"primaryKey" json:"id"`
	UserID             uint           `gorm:"not null" json:"user_id"`
	RecordDate         time.Time      `gorm:"type:date;uniqueIndex:idx_user_date,priority:1;not null" json:"record_date"` // Unique per user per date
	TotalCalories      float64        `gorm:"type:decimal(10,2);default:0.0" json:"total_calories"`
	TotalProtein       float64        `gorm:"type:decimal(10,2);default:0.0" json:"total_protein"`
	TotalCarbohydrates float64        `gorm:"type:decimal(10,2);default:0.0" json:"total_carbohydrates"`
	TotalFats          float64        `gorm:"type:decimal(10,2);default:0.0" json:"total_fats"`
	MicronutrientsJSON string         `gorm:"type:text" json:"micronutrients_json,omitempty"` // Storing as JSON string
	CreatedAt          time.Time      `json:"created_at"`
	UpdatedAt          time.Time      `json:"updated_at"`
	DeletedAt          gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty" swaggertype:"string"`
	User               User           `gorm:"foreignKey:UserID" json:"-"` // Belongs To User
}

// DailyNutritionSummaryResponse represents the response structure for daily nutrition summary.
type DailyNutritionSummaryResponse struct {
	ID                 uint      `json:"id"`
	UserID             uint      `json:"user_id"`
	RecordDate         time.Time `json:"record_date"`
	TotalCalories      float64   `json:"total_calories"`
	TotalProtein       float64   `json:"total_protein"`
	TotalCarbohydrates float64   `json:"total_carbohydrates"`
	TotalFats          float64   `json:"total_fats"`
	MicronutrientsJSON string    `json:"micronutrients_json,omitempty"`
	CreatedAt          time.Time `json:"created_at"`
}

// DailyNutritionModel provides methods for interacting with the daily_nutrition_summaries table.
type DailyNutritionModel struct {
	DB *gorm.DB
}

// GetDailyNutritionSummaryByUserIDAndDate retrieves a daily nutrition summary for a specific user and date.
func (m *DailyNutritionModel) GetDailyNutritionSummaryByUserIDAndDate(userID uint, date time.Time) (*DailyNutritionSummary, error) {
	var summary DailyNutritionSummary
	err := m.DB.Where("user_id = ? AND record_date = ?", userID, date.Format("2006-01-02")).First(&summary).Error
	if err != nil {
		return nil, err
	}
	return &summary, nil
}

// UpsertDailyNutritionSummary creates or updates a daily nutrition summary entry.
func (m *DailyNutritionModel) UpsertDailyNutritionSummary(summary *DailyNutritionSummary) error {
	var existingSummary DailyNutritionSummary
	err := m.DB.Where("user_id = ? AND record_date = ?", summary.UserID, summary.RecordDate.Format("2006-01-02")).First(&existingSummary).Error

	if err == gorm.ErrRecordNotFound {
		// No existing record, create a new one
		return m.DB.Create(summary).Error
	} else if err != nil {
		// Other database error
		return err
	}

	// Existing record found, update it
	existingSummary.TotalCalories += summary.TotalCalories
	existingSummary.TotalProtein += summary.TotalProtein
	existingSummary.TotalCarbohydrates += summary.TotalCarbohydrates
	existingSummary.TotalFats += summary.TotalFats

	// Merge micronutrients if both exist
	if existingSummary.MicronutrientsJSON != "" && summary.MicronutrientsJSON != "" {
		mergedMicros, err := utils.MergeJSONStrings(existingSummary.MicronutrientsJSON, summary.MicronutrientsJSON)
		if err != nil {
			return err
		}
		existingSummary.MicronutrientsJSON = mergedMicros
	} else if summary.MicronutrientsJSON != "" {
		existingSummary.MicronutrientsJSON = summary.MicronutrientsJSON
	}

	return m.DB.Save(&existingSummary).Error
}

// GetDailyNutritionSummariesByUserID retrieves all daily nutrition summaries for a specific user.
func (m *DailyNutritionModel) GetDailyNutritionSummariesByUserID(userID uint) ([]DailyNutritionSummary, error) {
	var summaries []DailyNutritionSummary
	err := m.DB.Where("user_id = ?", userID).Order("record_date desc").Find(&summaries).Error
	if err != nil {
		return nil, err
	}
	return summaries, nil
}