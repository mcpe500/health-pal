// Package handlers provides HTTP handlers for the backend application.
package handlers

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"health_pal_backend/models"
	"health_pal_backend/utils"
)

// AuthHandler holds dependencies for authentication related HTTP handlers.
type AuthHandler struct {
	UserModel *models.UserModel
	JWTSecret []byte // Add JWTSecret to AuthHandler
}

// GoogleLoginRequest defines the structure for the Google login request body.
type GoogleLoginRequest struct {
	IDToken string `json:"id_token" binding:"required"`
}

// GoogleLoginHandler handles Google authentication.
// It verifies the Google ID token, creates or updates a user in the database,
// and returns a JWT for subsequent authenticated requests.
func (h *AuthHandler) GoogleLoginHandler(c *gin.Context) {
	var req GoogleLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	payload, err := utils.VerifyGoogleIDToken(req.IDToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": fmt.Sprintf("failed to verify ID token: %v", err)})
		return
	}

	// Extract user information from payload
	googleID := payload.Subject
	email := payload.Claims["email"].(string)
	name := ""
	if payload.Claims["name"] != nil {
		name = payload.Claims["name"].(string)
	}
	profilePictureURL := ""
	if payload.Claims["picture"] != nil {
		profilePictureURL = payload.Claims["picture"].(string)
	}

	// Check if user exists in DB
	user, err := h.UserModel.GetByEmail(email)
	if err != nil && err != sql.ErrNoRows {
		log.Printf("Error getting user by email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	if user == nil {
		// User does not exist, create new user
		newUser := &models.User{
			GoogleID:          sql.NullString{String: googleID, Valid: true},
			Email:             email,
			Name:              sql.NullString{String: name, Valid: true},
			ProfilePictureURL: sql.NullString{String: profilePictureURL, Valid: true},
			Password:          sql.NullString{Valid: false}, // No password for Google authenticated users
		}
		err = h.UserModel.Insert(newUser)
		if err != nil {
			log.Printf("Error inserting new user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create user"})
			return
		}
		user = newUser // Use the newly created user for JWT generation
	} else {
		// User exists, update their information if needed
		user.GoogleID = sql.NullString{String: googleID, Valid: true}
		user.Name = sql.NullString{String: name, Valid: true}
		user.ProfilePictureURL = sql.NullString{String: profilePictureURL, Valid: true}
		err = h.UserModel.Update(user)
		if err != nil {
			log.Printf("Error updating user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update user"})
			return
		}
	}

	// Generate JWT using the secret from the handler's dependencies
	token, err := utils.GenerateJWT(user.ID, user.Email, h.JWTSecret)
	if err != nil {
		log.Printf("Error generating JWT: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}