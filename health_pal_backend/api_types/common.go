package api_types

// SuccessResponse represents a generic success response.
type SuccessResponse struct {
	Message string `json:"message"`
}

// ErrorResponse represents a generic error response.
type ErrorResponse struct {
	Error string `json:"error"`
}