.PHONY: run build test swagger clean

# Default target
all: run

# Run the Go Gin application
run:
	@echo "Starting Health Pal Backend..."
	go run main.go

# Build the Go Gin application
build:
	@echo "Building Health Pal Backend..."
	go build -o health_pal_backend main.go

# Run tests
test:
	@echo "Running tests..."
	go test ./...

# Generate Swagger documentation
swagger:
	@echo "Generating Swagger documentation..."
	swag init

# Clean up build artifacts
clean:
	@echo "Cleaning up..."
	go clean
	rm -f health_pal_backend # For Linux/macOS
	del health_pal_backend.exe # For Windows
	rm -rf docs/ # Remove generated swagger docs