// Package middleware provides Gin middleware functions for the backend application.
package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"health_pal_backend/utils"
)

// AuthMiddleware authenticates requests using JSON Web Tokens (JWT).
// It checks for a valid "Bearer" token in the Authorization header.
// If valid, it sets the "userID" and "userEmail" in the Gin context.
func AuthMiddleware(jwtSecret []byte) gin.HandlerFunc { // Accept jwtSecret as parameter
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization header format"})
			c.Abort()
			return
		}

		tokenString := parts[1]
		claims, err := utils.ValidateJWT(tokenString, jwtSecret) // Pass jwtSecret to ValidateJWT
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		c.Set("userID", claims.UserID)
		c.Set("userEmail", claims.Email)
		c.Next()
	}
}