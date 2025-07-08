package models

import (
	"time"

	"gorm.io/gorm"
)

// Reminder represents a scheduled reminder for a user.
type Reminder struct {
	ID            uint           `gorm:"primaryKey" json:"id"`
	UserID        uint           `gorm:"not null" json:"user_id"`
	ReminderText  string         `gorm:"type:text;not null" json:"reminder_text"`
	ScheduledTime time.Time      `gorm:"not null" json:"scheduled_time"`
	SentAt        *time.Time     `json:"sent_at,omitempty"`
	Status        string         `gorm:"size:50;not null;default:'pending'" json:"status"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
	User          User           `gorm:"foreignKey:UserID" json:"-"` // Belongs To User
}

// ReminderWithUser represents a reminder with user email for notifications.
type ReminderWithUser struct {
	ID        uint      `json:"id"`
	UserEmail string    `json:"user_email"`
	Message   string    `json:"message"`
	ScheduledTime time.Time `json:"scheduled_time"`
}

// ReminderResponse represents the response structure for a reminder.
type ReminderResponse struct {
	ID            uint       `json:"id"`
	UserID        uint       `json:"user_id"`
	ReminderText  string     `json:"reminder_text"`
	ScheduledTime time.Time  `json:"scheduled_time"`
	SentAt        *time.Time `json:"sent_at,omitempty"`
	Status        string     `json:"status"`
	CreatedAt     time.Time  `json:"created_at"`
}

// ReminderModel provides methods for interacting with the reminders table.
type ReminderModel struct {
	DB *gorm.DB
}

// CreateReminder creates a new reminder entry in the database.
func (m *ReminderModel) CreateReminder(reminder *Reminder) error {
	return m.DB.Create(reminder).Error
}

// GetRemindersByUserID retrieves all reminders for a given user ID.
func (m *ReminderModel) GetRemindersByUserID(userID uint) ([]Reminder, error) {
	var reminders []Reminder
	err := m.DB.Where("user_id = ?", userID).Order("scheduled_time desc").Find(&reminders).Error
	if err != nil {
		return nil, err
	}
	return reminders, nil
}

// GetPendingReminders retrieves all pending reminders scheduled before or at the current time.
func (m *ReminderModel) GetPendingReminders() ([]Reminder, error) {
	var reminders []Reminder
	err := m.DB.Where("status = ? AND scheduled_time <= ?", "pending", time.Now()).Find(&reminders).Error
	if err != nil {
		return nil, err
	}
	return reminders, nil
}

// UpdateReminder updates an existing reminder entry in the database.
func (m *ReminderModel) UpdateReminder(reminder *Reminder) error {
	return m.DB.Save(reminder).Error
}

// GetDueReminders retrieves all pending reminders that are due for notification.
func (m *ReminderModel) GetDueReminders() ([]ReminderWithUser, error) {
	var reminders []ReminderWithUser
	err := m.DB.Table("reminders").
		Select("reminders.id, users.email as user_email, reminders.reminder_text as message, reminders.scheduled_time").
		Joins("JOIN users ON reminders.user_id = users.id").
		Where("reminders.status = ? AND reminders.scheduled_time <= ? AND reminders.deleted_at IS NULL AND users.deleted_at IS NULL", "pending", time.Now()).
		Scan(&reminders).Error
	if err != nil {
		return nil, err
	}
	return reminders, nil
}

// MarkReminderAsSent marks a reminder as sent and updates the sent_at timestamp.
func (m *ReminderModel) MarkReminderAsSent(reminderID uint) error {
	now := time.Now()
	return m.DB.Model(&Reminder{}).
		Where("id = ?", reminderID).
		Updates(map[string]interface{}{
			"status":  "sent",
			"sent_at": &now,
		}).Error
}