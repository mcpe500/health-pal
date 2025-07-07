// Package routes defines and sets up all HTTP routes for the backend application.
package routes

import (
	"fmt" // Added for fmt.Sprintf
	"net/http" // Added for http.StatusOK, http.StatusInternalServerError

	"github.com/gin-gonic/gin"
	"health_pal_backend/handlers"
	"health_pal_backend/middleware"
)

// SetupRoutes initializes and registers all API routes with the Gin router.
// It takes the Gin router instance and handler dependencies as arguments.
func SetupRoutes(router *gin.Engine, authHandler *handlers.AuthHandler, deletionHandler *handlers.DeletionHandler) {
	// Public routes
	router.POST("/auth/google-login", authHandler.GoogleLoginHandler)

	// Account Deletion Web Routes
	router.GET("/delete-account", deletionHandler.ShowDeleteAccountForm)
	router.POST("/delete-account", deletionHandler.RequestDeleteAccountOTPWeb)
	router.GET("/delete-account/verify-otp", deletionHandler.ShowVerifyOTPForm)
	router.POST("/delete-account/verify-otp", deletionHandler.VerifyDeleteAccountOTPWeb)

	// API Version 1 Group
	apiV1 := router.Group("/api/v1")
	{
		// Protected routes (require JWT authentication)
		protected := apiV1.Group("/") // Group for protected API routes under /api/v1
		protected.Use(middleware.AuthMiddleware())
		{
			protected.GET("/profile", func(c *gin.Context) {
				userID, exists := c.Get("userID")
				if !exists {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "User ID not found in context"})
					return
				}
				userEmail, exists := c.Get("userEmail")
				if !exists {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "User email not found in context"})
					return
				}
				c.JSON(http.StatusOK, gin.H{
					"message": fmt.Sprintf("Welcome, User %v (%v)! This is a protected route.", userID, userEmail),
				})
			})
			// Account Deletion API Routes
			protected.POST("/delete-account/request-otp", deletionHandler.RequestDeleteAccountOTPAPI)
			protected.POST("/delete-account/verify-otp", deletionHandler.VerifyDeleteAccountOTPAPI)
		}
	}
}