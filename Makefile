# Health Pal - Comprehensive Makefile
.PHONY: help dev prod build-all build-apk build-ios build-web clean logs test

# Default target
help:
	@echo "🏥 Health Pal - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  make dev          - Start development environment"
	@echo "  make dev-logs     - View development logs"
	@echo "  make dev-stop     - Stop development environment"
	@echo ""
	@echo "Production:"
	@echo "  make prod         - Start production environment"
	@echo "  make prod-logs    - View production logs"
	@echo "  make prod-stop    - Stop production environment"
	@echo ""
	@echo "Building:"
	@echo "  make build-all    - Build all platforms (APK, iOS, Web)"
	@echo "  make build-apk    - Build Android APK"
	@echo "  make build-ios    - Build iOS (simulation)"
	@echo "  make build-web    - Build Web application"
	@echo "  make build-dashboard - Start build dashboard"
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
	docker-compose -f docker-compose.build.yml up -d
	@echo "✅ All builds started!"
	@echo "📱 APK Build: http://localhost:8081"
	@echo "🍎 iOS Build: http://localhost:8082"
	@echo "🌐 Web Build: http://localhost:8083"
	@echo "📊 Build Dashboard: http://localhost:8084"

build-apk:
	@echo "🔨 Building Android APK..."
	docker-compose -f docker-compose.build.yml up -d build-apk
	@echo "✅ APK build started!"
	@echo "📱 Download: http://localhost:8081"

build-ios:
	@echo "🔨 Building iOS (simulation)..."
	docker-compose -f docker-compose.build.yml up -d build-ios
	@echo "✅ iOS build started!"
	@echo "🍎 Info: http://localhost:8082"

build-web:
	@echo "🔨 Building Web application..."
	docker-compose -f docker-compose.build.yml up -d build-web
	@echo "✅ Web build started!"
	@echo "🌐 Launch: http://localhost:8083"

build-dashboard:
	@echo "📊 Starting build dashboard..."
	docker-compose -f docker-compose.build.yml up -d build-dashboard
	@echo "✅ Build dashboard started!"
	@echo "📊 Dashboard: http://localhost:8084"

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