package utils

import (
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"time"
)

// SaveUploadedFile saves a multipart file to the specified upload directory.
// It returns the relative path of the saved file and an error, if any.
func SaveUploadedFile(file *multipart.FileHeader, uploadDir string) (string, error) {
	src, err := file.Open()
	if err != nil {
		return "", fmt.Errorf("failed to open uploaded file: %w", err)
	}
	defer src.Close()

	// Create the upload directory if it doesn't exist
	if _, err := os.Stat(uploadDir); os.IsNotExist(err) {
		err = os.MkdirAll(uploadDir, 0755)
		if err != nil {
			return "", fmt.Errorf("failed to create upload directory: %w", err)
		}
	}

	// Generate a unique filename to prevent collisions
	filename := fmt.Sprintf("%d-%s", time.Now().UnixNano(), filepath.Base(file.Filename))
	destinationPath := filepath.Join(uploadDir, filename)

	dst, err := os.Create(destinationPath)
	if err != nil {
		return "", fmt.Errorf("failed to create destination file: %w", err)
	}
	defer dst.Close()

	if _, err := io.Copy(dst, src); err != nil {
		return "", fmt.Errorf("failed to copy file content: %w", err)
	}

	return filepath.Join(filepath.Base(uploadDir), filename), nil // Return relative path
}