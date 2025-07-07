// Package utils provides utility functions for the backend application.
package utils

import (
	"context"
	"errors"
	"fmt" // Added for fmt.Errorf
	"log"
	"os"

	"google.golang.org/api/idtoken"
	"google.golang.org/api/option"
)

// VerifyGoogleIDToken verifies the provided Google ID token.
// It takes the ID token string as input and returns the decoded payload if valid,
// or an error if the token is invalid or verification fails.
func VerifyGoogleIDToken(idToken string) (*idtoken.Payload, error) {
	clientID := os.Getenv("GOOGLE_CLIENT_ID")
	if clientID == "" {
		log.Println("GOOGLE_CLIENT_ID not set in environment variables.")
		return nil, errors.New("google client ID not configured")
	}

	// Create a context for the verification
	ctx := context.Background()

	// Use the idtoken.Validate method to verify the token.
	// The WithAudience option ensures the token was issued for our specific client ID.
	payload, err := idtoken.Validate(ctx, idToken, option.WithAudience(clientID))
	if err != nil {
		log.Printf("Failed to validate Google ID token: %v", err)
		return nil, fmt.Errorf("invalid Google ID token: %w", err)
	}

	return payload, nil
}