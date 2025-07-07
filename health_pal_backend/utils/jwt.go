// Package utils provides utility functions for the backend application.
package utils

import (
	"errors" // Added for errors.New
	"fmt"
	"os"
	"time"

	"github.com/dgrijalva/jwt-go/v4"
)

var jwtSecret = []byte(os.Getenv("JWT_SECRET"))

// Claims defines the structure of JWT claims for the application.
type Claims struct {
	UserID int    `json:"user_id"`
	Email  string `json:"email"`
	jwt.StandardClaims
}

// GenerateJWT generates a new JSON Web Token (JWT) for the given user ID and email.
// The token is signed with a secret key and expires after 24 hours.
func GenerateJWT(userID int, email string) (string, error) {
	claims := Claims{
		UserID: userID,
		Email:  email,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: jwt.At(time.Now().Add(24 * time.Hour)), // Token expires after 24 hours
			IssuedAt:  jwt.At(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtSecret)
	if err != nil {
		return "", fmt.Errorf("failed to sign token: %w", err)
	}
	return tokenString, nil
}

// ValidateJWT validates the given JWT token string.
// It returns the Claims extracted from the token if valid, or an error if the token
// is invalid, expired, or malformed.
func ValidateJWT(tokenString string) (*Claims, error) {
	claims := &Claims{}

	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return jwtSecret, nil
	})

	if err != nil {
		return nil, fmt.Errorf("failed to parse token: %w", err)
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}