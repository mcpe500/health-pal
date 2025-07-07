.PHONY: test-all-e2e test-api test-e2e

# ==============================================================================
# Main Testing Targets
# ==============================================================================

# Run all E2E and API tests
test-all: test-api test-e2e
	@echo "All tests completed."

# Run only the API tests using Jest
test-api:
	@echo "Running API tests..."
	cd health_pal_testing && npm test -- api_tests/

# Run only the Flutter APK E2E tests using WebdriverIO
test-e2e:
	@echo "Running Flutter APK E2E tests..."
	cd health_pal_testing && npx wdio run wdio.conf.ts

# ==============================================================================
# Backend and Frontend Helper Targets
# ==============================================================================

# Run the backend server
run-backend:
	@echo "Starting backend server..."
	cd health_pal_backend && make run

# Build the Flutter APK
build-flutter-apk:
	@echo "Building Flutter APK..."
	cd health_pal_frontend && flutter build apk --release

# ==============================================================================
# Cleanup Targets
# ==============================================================================

# Clean up all generated files and reports
clean:
	@echo "Cleaning up test reports and node modules..."
	rm -rf test_reports/
	cd health_pal_testing && rm -rf node_modules package-lock.json
	cd health_pal_backend && make clean