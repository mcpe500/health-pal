package handlers

import (
	"database/sql"
	"html/template"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"health_pal_backend/models"
	"health_pal_backend/utils"
)

// DeletionHandler holds dependencies for account deletion handlers
type DeletionHandler struct {
	UserModel *models.UserModel
}

// ShowDeleteAccountForm renders the HTML form for requesting account deletion OTP
func (h *DeletionHandler) ShowDeleteAccountForm(c *gin.Context) {
	tmpl, err := template.ParseFiles("templates/delete_account.html")
	if err != nil {
		log.Printf("Error parsing template: %v", err)
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}
	tmpl.Execute(c.Writer, nil)
}

// RequestDeleteAccountOTPWeb handles OTP request from web form
func (h *DeletionHandler) RequestDeleteAccountOTPWeb(c *gin.Context) {
	email := c.PostForm("email")
	if email == "" {
		c.String(http.StatusBadRequest, "Email is required")
		return
	}

	user, err := h.UserModel.GetByEmail(email)
	if err != nil {
		log.Printf("Error getting user by email for OTP request: %v", err)
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}
	if user == nil {
		c.String(http.StatusNotFound, "User not found")
		return
	}

	otp, err := utils.GenerateOTP()
	if err != nil {
		log.Printf("Error generating OTP: %v", err)
		c.String(http.StatusInternalServerError, "Failed to generate OTP")
		return
	}

	user.OTPSecret = sql.NullString{String: otp, Valid: true}
	user.OTPCreatedAt = sql.NullTime{Time: time.Now(), Valid: true}
	if err := h.UserModel.Update(user); err != nil {
		log.Printf("Error saving OTP to user: %v", err)
		c.String(http.StatusInternalServerError, "Failed to save OTP")
		return
	}

	if err := utils.SendOTPEmail(email, otp); err != nil {
		log.Printf("Error sending OTP email: %v", err)
		c.String(http.StatusInternalServerError, "Failed to send OTP email")
		return
	}

	c.Redirect(http.StatusFound, "/delete-account/verify-otp?email="+email)
}

// ShowVerifyOTPForm renders the HTML form for OTP verification
func (h *DeletionHandler) ShowVerifyOTPForm(c *gin.Context) {
	email := c.Query("email")
	tmpl, err := template.ParseFiles("templates/verify_otp.html")
	if err != nil {
		log.Printf("Error parsing template: %v", err)
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}
	tmpl.Execute(c.Writer, gin.H{"Email": email})
}

// VerifyDeleteAccountOTPWeb handles OTP verification from web form and soft deletes account
func (h *DeletionHandler) VerifyDeleteAccountOTPWeb(c *gin.Context) {
	email := c.PostForm("email")
	otp := c.PostForm("otp")

	user, err := h.UserModel.GetByEmail(email)
	if err != nil {
		log.Printf("Error getting user by email for OTP verification: %v", err)
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}
	if user == nil {
		c.String(http.StatusNotFound, "User not found")
		return
	}

	if !user.OTPSecret.Valid || !user.OTPCreatedAt.Valid {
		c.String(http.StatusBadRequest, "No OTP requested for this user")
		return
	}

	if !utils.IsOTPValid(otp, user.OTPSecret.String, user.OTPCreatedAt.Time, 5) { // OTP valid for 5 minutes
		c.String(http.StatusUnauthorized, "Invalid or expired OTP")
		return
	}

	// Soft delete the user
	if err := h.UserModel.SoftDelete(user.ID); err != nil {
		log.Printf("Error soft deleting user: %v", err)
		c.String(http.StatusInternalServerError, "Failed to delete account")
		return
	}

	tmpl, err := template.ParseFiles("templates/deletion_result.html")
	if err != nil {
		log.Printf("Error parsing template: %v", err)
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}
	tmpl.Execute(c.Writer, gin.H{"Success": true, "Message": "Account successfully deleted."})
}

// RequestDeleteAccountOTPAPI handles OTP request from API (Flutter app)
func (h *DeletionHandler) RequestDeleteAccountOTPAPI(c *gin.Context) {
	// Assuming email is passed in the JWT or request body for API
	// For simplicity, let's assume email is in the request body for now, or extracted from JWT claims
	var req struct {
		Email string `json:"email" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := h.UserModel.GetByEmail(req.Email)
	if err != nil {
		log.Printf("Error getting user by email for API OTP request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}
	if user == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	otp, err := utils.GenerateOTP()
	if err != nil {
		log.Printf("Error generating OTP for API: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate OTP"})
		return
	}

	user.OTPSecret = sql.NullString{String: otp, Valid: true}
	user.OTPCreatedAt = sql.NullTime{Time: time.Now(), Valid: true}
	if err := h.UserModel.Update(user); err != nil {
		log.Printf("Error saving OTP to user for API: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save OTP"})
		return
	}

	if err := utils.SendOTPEmail(req.Email, otp); err != nil {
		log.Printf("Error sending OTP email for API: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to send OTP email"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP sent successfully"})
}

// VerifyDeleteAccountOTPAPI handles OTP verification from API and soft deletes account
func (h *DeletionHandler) VerifyDeleteAccountOTPAPI(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required"`
		OTP   string `json:"otp" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := h.UserModel.GetByEmail(req.Email)
	if err != nil {
		log.Printf("Error getting user by email for API OTP verification: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}
	if user == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	if !user.OTPSecret.Valid || !user.OTPCreatedAt.Valid {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no OTP requested for this user"})
		return
	}

	if !utils.IsOTPValid(req.OTP, user.OTPSecret.String, user.OTPCreatedAt.Time, 5) { // OTP valid for 5 minutes
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired OTP"})
		return
	}

	// Soft delete the user
	if err := h.UserModel.SoftDelete(user.ID); err != nil {
		log.Printf("Error soft deleting user for API: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete account"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Account successfully deleted"})
}