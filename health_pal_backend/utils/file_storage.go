package utils

import (
	"encoding/json"
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

// MergeJSONStrings merges two JSON strings.
// This function is used to merge micronutrient data from different sources.
func MergeJSONStrings(json1, json2 string) (string, error) {
	var map1, map2 map[string]float64

	err := json.Unmarshal([]byte(json1), &map1)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal first JSON string: %w", err)
	}

	err = json.Unmarshal([]byte(json2), &map2)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal second JSON string: %w", err)
	}

	mergedMap := make(map[string]float64)
	for k, v := range map1 {
		mergedMap[k] = v
	}
	for k, v := range map2 {
		mergedMap[k] += v // Add values if key exists, otherwise add new key
	}

	mergedJSON, err := json.Marshal(mergedMap)
	if err != nil {
		return "", fmt.Errorf("failed to marshal merged map to JSON: %w", err)
	}

	return string(mergedJSON), nil
}