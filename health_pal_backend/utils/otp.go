// Package utils provides utility functions for the backend application.
package utils

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"time"
)

// GenerateOTP generates a random 6-digit One-Time Password (OTP).
// It returns the generated OTP as a string and an error if generation fails.
func GenerateOTP() (string, error) {
	const otpLength = 6
	const charset = "0123456789"
	otp := make([]byte, otpLength)
	for i := 0; i < otpLength; i++ {
		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
		if err != nil {
			return "", fmt.Errorf("failed to generate random number for OTP: %w", err)
		}
		otp[i] = charset[num.Int64()]
	}
	return string(otp), nil
}

// IsOTPValid checks if the provided OTP matches the stored secret and is within the specified expiry time.
// It takes the OTP entered by the user, the stored OTP secret, the creation timestamp of the OTP,
// and the expiry duration in minutes. Returns true if valid, false otherwise.
func IsOTPValid(generatedOTP, storedOTPSecret string, otpCreatedAt time.Time, expiryMinutes int) bool {
	if generatedOTP != storedOTPSecret {
		return false
	}
	// Check if OTP has expired
	if time.Since(otpCreatedAt) > time.Duration(expiryMinutes)*time.Minute {
		return false
	}
	return true
}