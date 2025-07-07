// Package models defines the data structures and database interaction logic for the application.
package models

import (
	"database/sql"
	"time"
)

// User represents a user in the database.
// It includes fields for Google authentication, account deletion, and general user information.
type User struct {
	ID                int            `json:"id"`
	GoogleID          sql.NullString `json:"google_id"`
	Name              sql.NullString `json:"name"`
	Email             string         `json:"email"`
	Password          sql.NullString `json:"password"`
	ProfilePictureURL sql.NullString `json:"profile_picture_url"`
	DeletedAt         sql.NullTime   `json:"deleted_at"`
	OTPSecret         sql.NullString `json:"otp_secret"`
	OTPCreatedAt      sql.NullTime   `json:"otp_created_at"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	Fullname          sql.NullString `json:"fullname"`
	Username          sql.NullString `json:"username"`
}

// UserModel provides methods for interacting with the 'users' table in the database.
type UserModel struct {
	DB *sql.DB
}

// Insert inserts a new user record into the 'users' table.
// It takes a pointer to a User struct and returns an error if the operation fails.
func (m *UserModel) Insert(user *User) error {
	stmt := `INSERT INTO users (google_id, name, email, password, profile_picture_url, otp_secret, otp_created_at, fullname, username)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
	_, err := m.DB.Exec(stmt,
		user.GoogleID,
		user.Name,
		user.Email,
		user.Password,
		user.ProfilePictureURL,
		user.DeletedAt, // Corrected to use user.DeletedAt
		user.OTPSecret,
		user.OTPCreatedAt,
		user.Fullname,
		user.Username,
	)
	if err != nil {
		return err
	}
	return nil
}

// GetByEmail retrieves a user record from the 'users' table by their email address.
// It returns a pointer to a User struct if found, or nil and an error if not found or an error occurs.
func (m *UserModel) GetByEmail(email string) (*User, error) {
	stmt := `SELECT id, google_id, name, email, password, profile_picture_url, deleted_at, otp_secret, otp_created_at, created_at, updated_at, fullname, username
             FROM users WHERE email = ?`
	row := m.DB.QueryRow(stmt, email)

	user := &User{}
	err := row.Scan(
		&user.ID,
		&user.GoogleID,
		&user.Name,
		&user.Email,
		&user.Password,
		&user.ProfilePictureURL,
		&user.DeletedAt,
		&user.OTPSecret,
		&user.OTPCreatedAt,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.Fullname,
		&user.Username,
	)
	if err == sql.ErrNoRows {
		return nil, nil // User not found
	}
	if err != nil {
		return nil, err
	}
	return user, nil
}

// Update updates an existing user record in the 'users' table.
// It takes a pointer to a User struct and returns an error if the operation fails.
func (m *UserModel) Update(user *User) error {
	stmt := `UPDATE users SET google_id = ?, name = ?, email = ?, password = ?, profile_picture_url = ?, deleted_at = ?, otp_secret = ?, otp_created_at = ?, fullname = ?, username = ?, updated_at = NOW() WHERE id = ?`
	_, err := m.DB.Exec(stmt,
		user.GoogleID,
		user.Name,
		user.Email,
		user.Password,
		user.ProfilePictureURL,
		user.DeletedAt,
		user.OTPSecret,
		user.OTPCreatedAt,
		user.Fullname,
		user.Username,
		user.ID,
	)
	if err != nil {
		return err
	}
	return nil
}

// SoftDelete marks a user as deleted by setting the 'deleted_at' timestamp.
// It takes the user ID and returns an error if the operation fails.
func (m *UserModel) SoftDelete(userID int) error {
	stmt := `UPDATE users SET deleted_at = NOW() WHERE id = ?`
	_, err := m.DB.Exec(stmt, userID)
	if err != nil {
		return err
	}
	return nil
}