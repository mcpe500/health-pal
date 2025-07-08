package utils

import (
	"fmt"
	"log"
	"net/smtp"
	"os"
	"strings"
)

// SendEmailNotification sends an email notification to the specified recipient.
func SendEmailNotification(toEmail, subject, body string) error {
	from := os.Getenv("EMAIL_FROM")
	password := os.Getenv("EMAIL_PASSWORD")
	smtpHost := os.Getenv("EMAIL_HOST")
	smtpPort := os.Getenv("EMAIL_PORT")

	if from == "" || password == "" || smtpHost == "" || smtpPort == "" {
		return fmt.Errorf("email environment variables are not fully set")
	}

	msg := []byte(
		"To: " + toEmail + "\r\n" +
			"From: " + from + "\r\n" +
			"Subject: " + subject + "\r\n" +
			"Content-Type: text/plain; charset=UTF-8\r\n" +
			"\r\n" +
			body + "\r\n")

	auth := smtp.PlainAuth("", from, password, smtpHost)

	addr := fmt.Sprintf("%s:%s", smtpHost, smtpPort)
	err := smtp.SendMail(addr, auth, from, []string{toEmail}, msg)
	if err != nil {
		log.Printf("Error sending email to %s: %v", toEmail, err)
		return fmt.Errorf("failed to send email: %w", err)
	}

	log.Printf("Email sent successfully to %s", toEmail)
	return nil
}