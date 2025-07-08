package utils

import (
	"fmt"
	"os"

	"gopkg.in/mail.v2"
)

// SendNotification sends a notification to the user via email.
// This is a simple implementation using email as the notification channel.
// In a production environment, you might want to integrate with Firebase Cloud Messaging
// or other push notification services.
func SendNotification(userEmail, subject, message string) error {
	// Get email configuration from environment variables
	emailHost := os.Getenv("EMAIL_HOST")
	emailPort := 587 // Default SMTP port
	emailUsername := os.Getenv("EMAIL_USERNAME")
	emailPassword := os.Getenv("EMAIL_PASSWORD")
	emailFrom := os.Getenv("EMAIL_FROM")

	if emailHost == "" || emailUsername == "" || emailPassword == "" || emailFrom == "" {
		return fmt.Errorf("email configuration not properly set in environment variables")
	}

	// Create a new message
	m := mail.NewMessage()
	m.SetHeader("From", emailFrom)
	m.SetHeader("To", userEmail)
	m.SetHeader("Subject", subject)
	m.SetBody("text/html", fmt.Sprintf(`
		<html>
		<body>
			<h2>Health Pal Reminder</h2>
			<p>%s</p>
			<br>
			<p>Best regards,<br>Health Pal Team</p>
		</body>
		</html>
	`, message))

	// Create a new dialer
	d := mail.NewDialer(emailHost, emailPort, emailUsername, emailPassword)

	// Send the email
	if err := d.DialAndSend(m); err != nil {
		return fmt.Errorf("failed to send notification email: %w", err)
	}

	return nil
}

// SendPushNotification is a placeholder for future push notification implementation
// This would integrate with Firebase Cloud Messaging or similar services
func SendPushNotification(deviceToken, title, body string) error {
	// TODO: Implement push notification logic
	// For now, we'll just log that a push notification would be sent
	fmt.Printf("Push notification would be sent to device %s: %s - %s\n", deviceToken, title, body)
	return nil
}