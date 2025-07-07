// Package utils provides utility functions for the backend application.
package utils

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"gopkg.in/mail.v2"
)

// SendOTPEmail sends an OTP (One-Time Password) to the specified email address.
// It retrieves email configuration from environment variables.
func SendOTPEmail(toEmail, otp string) error {
	emailHost := os.Getenv("EMAIL_HOST")
	emailPortStr := os.Getenv("EMAIL_PORT")
	emailUsername := os.Getenv("EMAIL_USERNAME")
	emailPassword := os.Getenv("EMAIL_PASSWORD")
	fromEmail := os.Getenv("EMAIL_FROM")

	emailPort, err := strconv.Atoi(emailPortStr)
	if err != nil {
		log.Printf("Invalid EMAIL_PORT: %v", err)
		return fmt.Errorf("invalid email port configuration")
	}

	m := mail.NewMessage()
	m.SetHeader("From", fromEmail)
	m.SetHeader("To", toEmail)
	m.SetHeader("Subject", "Your Health Pal Account Deletion OTP")
	m.SetBody("text/plain", fmt.Sprintf("Your OTP for account deletion is: %s. This OTP is valid for 5 minutes.", otp))

	d := mail.NewDialer(emailHost, emailPort, emailUsername, emailPassword)

	if err := d.DialAndSend(m); err != nil {
		log.Printf("Failed to send email to %s: %v", toEmail, err)
		return fmt.Errorf("failed to send OTP email: %w", err)
	}

	log.Printf("OTP email sent to %s", toEmail)
	return nil
}