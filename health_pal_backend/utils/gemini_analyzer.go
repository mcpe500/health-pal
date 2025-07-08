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
// and returns detected food items, estimated total calories, and macronutrients.
func AnalyzeFoodImageWithGemini(imagePath string) (string, float64, float64, float64, float64, string, error) {
	ctx := context.Background()
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return "", 0, 0, 0, 0, "", fmt.Errorf("GEMINI_API_KEY environment variable not set")
	}

	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return "", 0, 0, 0, 0, "", fmt.Errorf("failed to create Gemini client: %w", err)
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-pro-vision")

	imageData, err := ioutil.ReadFile(imagePath)
	if err != nil {
		return "", 0, 0, 0, 0, "", fmt.Errorf("failed to read image file: %w", err)
	}

	// Create parts for the multimodal prompt
	// Requesting detailed nutritional information including macronutrients and some key micronutrients.
	prompt := `Analyze this food image and provide the following information:
- Detected food items
- Estimated total calorie count
- Estimated protein (in grams)
- Estimated carbohydrates (in grams)
- Estimated fats (in grams)
- Key micronutrients and their estimated amounts (e.g., Vitamin C, Iron, Calcium, etc.)

Format the response as:
Items: [item1, item2, ...]
Calories: [number]
Protein: [number]g
Carbs: [number]g
Fats: [number]g
Micronutrients: { "Vitamin C": "Xmg", "Iron": "Ymg" }`

	imgPart := genai.ImageData("image/jpeg", imageData) // Assuming JPEG, adjust if other formats are expected

	resp, err := model.GenerateContent(ctx, genai.Text(prompt), imgPart)
	if err != nil {
		return "", 0, 0, 0, 0, "", fmt.Errorf("failed to generate content from Gemini API: %w", err)
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return "", 0, 0, 0, 0, "", fmt.Errorf("no content generated from Gemini API")
	}

	resultText := fmt.Sprintf("%v", resp.Candidates[0].Content.Parts[0])

	// Parse the response
	detectedItems := "Unknown"
	totalCalories := 0.0
	totalProtein := 0.0
	totalCarbohydrates := 0.0
	totalFats := 0.0
	micronutrientsJSON := "{}"

	lines := strings.Split(resultText, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "Items:") {
			detectedItems = strings.TrimPrefix(line, "Items:")
			detectedItems = strings.TrimSpace(detectedItems)
		} else if strings.HasPrefix(line, "Calories:") {
			caloriesStr := strings.TrimPrefix(line, "Calories:")
			calories, err := strconv.ParseFloat(strings.TrimSuffix(strings.TrimSpace(caloriesStr), "kcal"), 64)
			if err == nil {
				totalCalories = calories
			}
		} else if strings.HasPrefix(line, "Protein:") {
			proteinStr := strings.TrimPrefix(line, "Protein:")
			protein, err := strconv.ParseFloat(strings.TrimSuffix(strings.TrimSpace(proteinStr), "g"), 64)
			if err == nil {
				totalProtein = protein
			}
		} else if strings.HasPrefix(line, "Carbs:") {
			carbsStr := strings.TrimPrefix(line, "Carbs:")
			carbs, err := strconv.ParseFloat(strings.TrimSuffix(strings.TrimSpace(carbsStr), "g"), 64)
			if err == nil {
				totalCarbohydrates = carbs
			}
		} else if strings.HasPrefix(line, "Fats:") {
			fatsStr := strings.TrimPrefix(line, "Fats:")
			fats, err := strconv.ParseFloat(strings.TrimSuffix(strings.TrimSpace(fatsStr), "g"), 64)
			if err == nil {
				totalFats = fats
			}
		} else if strings.HasPrefix(line, "Micronutrients:") {
			microsStr := strings.TrimPrefix(line, "Micronutrients:")
			micronutrientsJSON = strings.TrimSpace(microsStr)
		}
	}

	return detectedItems, totalCalories, totalProtein, totalCarbohydrates, totalFats, micronutrientsJSON, nil
}

// Helper function to decode base64 image (if needed for other parts of the app)
func DecodeBase64Image(base64String string) ([]byte, error) {
	return base64.StdEncoding.DecodeString(base64String)
}