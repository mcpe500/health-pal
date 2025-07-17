# Health Pal - Comprehensive Makefile
.PHONY: help dev prod build-all build-apk build-ios build-web clean logs test

# Default target
help:
	@echo "🏥 Health Pal - Available Commands:"
	@echo ""
	@echo "Development (Docker):"
	@echo "  make dev          - Start development environment"
	@echo "  make dev-logs     - View development logs"
	@echo "  make dev-stop     - Stop development environment"
	@echo ""
	@echo "Development (Podman):"
	@echo "  make dev-podman   - Start development environment with Podman"
	@echo "  make dev-podman-logs - View Podman development logs"
	@echo "  make dev-podman-stop - Stop Podman development environment"
	@echo ""
	@echo "Production (Docker):"
	@echo "  make prod         - Start production environment"
	@echo "  make prod-logs    - View production logs"
	@echo "  make prod-stop    - Stop production environment"
	@echo ""
	@echo "Building (Docker):"
	@echo "  make build-all    - Build all platforms (APK, iOS, Web)"
	@echo "  make build-apk    - Build Android APK"
	@echo "  make build-ios    - Build iOS (simulation)"
	@echo "  make build-web    - Build Web application"
	@echo "  make build-dashboard - Start build dashboard"
	@echo ""
	@echo "Building (Podman):"
	@echo "  make build-all-podman - Build all platforms with Podman"
	@echo "  make build-apk-podman - Build Android APK with Podman"
	@echo "  make build-ios-podman - Build iOS with Podman"
	@echo "  make build-web-podman - Build Web with Podman"
	@echo ""
	@echo "Database:"
	@echo "  make db-migrate   - Run database migrations"
	@echo "  make db-seed      - Seed database with sample data"
	@echo "  make db-reset     - Reset database"
	@echo ""
	@echo "Testing:"
	@echo "  make test         - Run all tests"
	@echo "  make test-backend - Run backend tests"
	@echo "  make test-frontend - Run frontend tests"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean        - Clean up containers and volumes"
	@echo "  make clean-all    - Clean everything including images"
	@echo "  make logs         - View all logs"
	@echo "  make status       - Show container status"

# Development Environment
dev:
	@echo "🚀 Starting Health Pal development environment..."
	docker-compose up -d
	@echo "✅ Development environment started!"
	@echo "📱 Frontend: http://localhost:3000"
	@echo "🔧 Backend API: http://localhost:8080"
	@echo "📚 API Docs: http://localhost:8080/swagger/index.html"
	@echo "🗄️  Database: localhost:3306"

dev-logs:
	docker-compose logs -f

dev-stop:
	@echo "🛑 Stopping development environment..."
	docker-compose down
	@echo "✅ Development environment stopped!"

# Production Environment
prod:
	@echo "🚀 Starting Health Pal production environment..."
	docker-compose -f docker-compose.prod.yml up -d
	@echo "✅ Production environment started!"
	@echo "🌐 Application: http://localhost"
	@echo "📊 Health Check: http://localhost/health"

prod-logs:
	docker-compose -f docker-compose.prod.yml logs -f

prod-stop:
	@echo "🛑 Stopping production environment..."
	docker-compose -f docker-compose.prod.yml down
	@echo "✅ Production environment stopped!"

# Build Commands
build-all:
	@echo "🔨 Building all platforms..."
	@mkdir -p builds/apk builds/web builds/ios
	docker-compose -f docker-compose.build.yml up --build build-apk build-web build-ios
	docker-compose -f docker-compose.build.yml up -d serve-apk serve-web serve-ios build-dashboard
	@echo "✅ All builds completed!"
	@echo "📱 APK Files: ./builds/apk/ (also http://localhost:8081)"
	@echo "🌐 Web Files: ./builds/web/ (also http://localhost:8083)"
	@echo "🍎 iOS Info: ./builds/ios/ (also http://localhost:8082)"
	@echo "📊 Build Dashboard: http://localhost:8084"

build-apk:
	@echo "🔨 Building Android APK..."
	@mkdir -p builds/apk
	docker-compose -f docker-compose.build.yml up --build build-apk
	docker-compose -f docker-compose.build.yml up -d serve-apk
	@echo "✅ APK build completed!"
	@echo "📱 APK Files: ./builds/apk/"
	@echo "📱 Download Server: http://localhost:8081"
	@ls -la builds/apk/ 2>/dev/null || echo "No APK files found - check build logs"

build-ios:
	@echo "🔨 Building iOS (simulation)..."
	@mkdir -p builds/ios
	docker-compose -f docker-compose.build.yml up --build build-ios
	docker-compose -f docker-compose.build.yml up -d serve-ios
	@echo "✅ iOS build completed!"
	@echo "🍎 iOS Info: ./builds/ios/"
	@echo "🍎 Info Server: http://localhost:8082"

build-web:
	@echo "🔨 Building Web application..."
	@mkdir -p builds/web
	docker-compose -f docker-compose.build.yml up --build build-web
	docker-compose -f docker-compose.build.yml up -d serve-web
	@echo "✅ Web build completed!"
	@echo "🌐 Web Files: ./builds/web/"
	@echo "🌐 Web Server: http://localhost:8083"

build-dashboard:
	@echo "📊 Starting build dashboard..."
	docker-compose -f docker-compose.build.yml up -d build-dashboard
	@echo "✅ Build dashboard started!"
	@echo "📊 Dashboard: http://localhost:8084"

# Quick APK build for external access
apk:
	@echo "🚀 Quick APK build for external access..."
	@mkdir -p builds/apk
	docker-compose -f docker-compose.build.yml up --build build-apk
	@echo "✅ APK ready for external access!"
	@echo "📱 APK Files available at: ./builds/apk/"
	@ls -la builds/apk/*.apk 2>/dev/null || echo "No APK files found - check build logs"

# Database Commands
db-migrate:
	@echo "🗄️  Running database migrations..."
	docker-compose exec backend go run migration/migrate.go
	@echo "✅ Database migrations completed!"

db-seed:
	@echo "🌱 Seeding database with sample data..."
	docker-compose exec mysql mysql -u health_pal_user -phealth_pal_password health_pal < migration/seed.sql
	@echo "✅ Database seeded!"

db-reset:
	@echo "🔄 Resetting database..."
	docker-compose down
	docker volume rm health-pal_mysql_data || true
	docker-compose up -d mysql
	@echo "⏳ Waiting for database to be ready..."
	sleep 30
	make db-migrate
	@echo "✅ Database reset completed!"

# Testing Commands
test:
	@echo "🧪 Running all tests..."
	make test-backend
	make test-frontend
	@echo "✅ All tests completed!"

test-backend:
	@echo "🧪 Running backend tests..."
	cd health_pal_backend && go test ./...
	@echo "✅ Backend tests completed!"

test-frontend:
	@echo "🧪 Running frontend tests..."
	cd health_pal_frontend && flutter test
	@echo "✅ Frontend tests completed!"

# Maintenance Commands
logs:
	docker-compose logs -f

status:
	@echo "📊 Container Status:"
	docker-compose ps

clean:
	@echo "🧹 Cleaning up containers and volumes..."
	docker-compose down -v
	docker-compose -f docker-compose.prod.yml down -v
	docker-compose -f docker-compose.build.yml down -v
	docker system prune -f
	@echo "✅ Cleanup completed!"

clean-all:
	@echo "🧹 Cleaning everything including images..."
	docker-compose down -v --rmi all
	docker-compose -f docker-compose.prod.yml down -v --rmi all
	docker-compose -f docker-compose.build.yml down -v --rmi all
	docker system prune -af
	@echo "✅ Complete cleanup finished!"

# Environment Setup
setup:
	@echo "⚙️  Setting up Health Pal environment..."
	@if [ ! -f .env ]; then \
		echo "📝 Creating .env file..."; \
		cp .env.example .env; \
		echo "⚠️  Please edit .env file with your configuration"; \
	fi
	@if [ ! -f health_pal_backend/.env ]; then \
		echo "📝 Creating backend .env file..."; \
		cp health_pal_backend/.env.example health_pal_backend/.env; \
	fi
	@if [ ! -f health_pal_frontend/.env ]; then \
		echo "📝 Creating frontend .env file..."; \
		echo "API_BASE_URL=http://localhost:8080" > health_pal_frontend/.env; \
	fi
	@echo "✅ Environment setup completed!"
	@echo "📝 Please review and update .env files before running 'make dev'"

# Quick Start
quick-start: setup dev
	@echo "🎉 Health Pal is ready!"
	@echo "📱 Frontend: http://localhost:3000"
	@echo "🔧 Backend: http://localhost:8080"

# Podman Development Environment
dev-podman:
	@echo "🚀 Starting Health Pal development environment with Podman..."
	podman-compose -f docker-compose.podman.yml up -d
	@echo "✅ Podman development environment started!"
	@echo "📱 Frontend: http://localhost:3000"
	@echo "🔧 Backend API: http://localhost:8080"
	@echo "📚 API Docs: http://localhost:8080/swagger/index.html"
	@echo "🗄️  Database: localhost:3306"

dev-podman-logs:
	podman-compose -f docker-compose.podman.yml logs -f

dev-podman-stop:
	@echo "🛑 Stopping Podman development environment..."
	podman-compose -f docker-compose.podman.yml down
	@echo "✅ Podman development environment stopped!"

# Podman Build Commands
build-all-podman:
	@echo "🔨 Building all platforms with Podman..."
	podman-compose -f docker-compose.build.podman.yml up -d
	@echo "✅ All Podman builds started!"
	@echo "📱 APK Build: http://localhost:8091"
	@echo "🍎 iOS Build: http://localhost:8092"
	@echo "🌐 Web Build: http://localhost:8093"
	@echo "📊 Build Dashboard: http://localhost:8094"

build-apk-podman:
	@echo "🔨 Building Android APK with Podman..."
	podman-compose -f docker-compose.build.podman.yml up -d build-apk-podman
	@echo "✅ Podman APK build started!"
	@echo "📱 Download: http://localhost:8091"

build-ios-podman:
	@echo "🔨 Building iOS with Podman..."
	podman-compose -f docker-compose.build.podman.yml up -d build-ios-podman
	@echo "✅ Podman iOS build started!"
	@echo "🍎 Info: http://localhost:8092"

build-web-podman:
	@echo "🔨 Building Web application with Podman..."
	podman-compose -f docker-compose.build.podman.yml up -d build-web-podman
	@echo "✅ Podman Web build started!"
	@echo "🌐 Launch: http://localhost:8093"

# Podman Maintenance Commands
clean-podman:
	@echo "🧹 Cleaning up Podman containers and volumes..."
	podman-compose -f docker-compose.podman.yml down -v
	podman-compose -f docker-compose.build.podman.yml down -v
	podman system prune -f
	@echo "✅ Podman cleanup completed!"

status-podman:
	@echo "📊 Podman Container Status:"
	podman-compose -f docker-compose.podman.yml ps

# Health Check
health:
	@echo "🏥 Health Pal System Status:"
	@echo ""
	@echo "Backend API:"
	@curl -s http://localhost:8080/health || echo "❌ Backend not responding"
	@echo ""
	@echo "Frontend:"
	@curl -s http://localhost:3000/health || echo "❌ Frontend not responding"
	@echo ""
	@echo "Database:"
	@docker-compose exec mysql mysqladmin ping -h localhost --silent && echo "✅ Database is healthy" || echo "❌ Database not responding"