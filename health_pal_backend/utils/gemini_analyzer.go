package utils

import (
	"context"
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

// AnalyzeFoodImageWithGemini takes the path to a food image, sends it to the Gemini API,
// and returns detected food items and estimated total calories.
func AnalyzeFoodImageWithGemini(imagePath string) (string, float64, error) {
	ctx := context.Background()
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return "", 0, fmt.Errorf("GEMINI_API_KEY environment variable not set")
	}

	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return "", 0, fmt.Errorf("failed to create Gemini client: %w", err)
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-pro-vision")

	imageData, err := ioutil.ReadFile(imagePath)
	if err != nil {
		return "", 0, fmt.Errorf("failed to read image file: %w", err)
	}

	// Create parts for the multimodal prompt
	prompt := "Analyze this food image and provide a list of detected food items and an estimated total calorie count. Format the response as: Items: [item1, item2, ...], Calories: [number]."
	imgPart := genai.ImageData("image/jpeg", imageData) // Assuming JPEG, adjust if other formats are expected

	resp, err := model.GenerateContent(ctx, genai.Text(prompt), imgPart)
	if err != nil {
		return "", 0, fmt.Errorf("failed to generate content from Gemini API: %w", err)
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return "", 0, fmt.Errorf("no content generated from Gemini API")
	}

	resultText := fmt.Sprintf("%v", resp.Candidates[0].Content.Parts[0])

	// Parse the response
	detectedItems := "Unknown"
	totalCalories := 0.0

	lines := strings.Split(resultText, "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, "Items:") {
			itemsStr := strings.TrimPrefix(line, "Items:")
			detectedItems = strings.TrimSpace(itemsStr)
		} else if strings.HasPrefix(line, "Calories:") {
			caloriesStr := strings.TrimPrefix(line, "Calories:")
			caloriesStr = strings.TrimSpace(caloriesStr)
			calories, err := strconv.ParseFloat(caloriesStr, 64)
			if err == nil {
				totalCalories = calories
			}
		}
	}

	return detectedItems, totalCalories, nil
}

// Helper function to decode base64 image (if needed for other parts of the app)
func DecodeBase64Image(base64String string) ([]byte, error) {
	return base64.StdEncoding.DecodeString(base64String)
}