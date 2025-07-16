#!/bin/bash

# Health Pal Setup Script
# This script sets up the Health Pal application for development

set -e

echo "🏥 Health Pal Setup Script"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    print_status "Docker is installed"
}

# Check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    print_status "Docker Compose is installed"
}

# Check if Make is installed
check_make() {
    if ! command -v make &> /dev/null; then
        print_warning "Make is not installed. You can still use docker-compose commands directly."
    else
        print_status "Make is installed"
    fi
}

# Create environment files
setup_env_files() {
    print_info "Setting up environment files..."
    
    # Main .env file
    if [ ! -f .env ]; then
        cp .env.example .env
        print_status "Created main .env file"
    else
        print_warning ".env file already exists, skipping"
    fi
    
    # Backend .env file
    if [ ! -f health_pal_backend/.env ]; then
        cp health_pal_backend/.env.example health_pal_backend/.env
        print_status "Created backend .env file"
    else
        print_warning "Backend .env file already exists, skipping"
    fi
    
    # Frontend .env file
    if [ ! -f health_pal_frontend/.env ]; then
        echo "API_BASE_URL=http://localhost:8080" > health_pal_frontend/.env
        print_status "Created frontend .env file"
    else
        print_warning "Frontend .env file already exists, skipping"
    fi
}

# Create necessary directories
create_directories() {
    print_info "Creating necessary directories..."
    
    mkdir -p nginx/ssl
    mkdir -p nginx/logs
    mkdir -p mysql/conf.d
    mkdir -p health_pal_backend/uploads
    
    print_status "Directories created"
}

# Generate JWT secret
generate_jwt_secret() {
    print_info "Generating JWT secret..."
    
    # Generate a random JWT secret
    JWT_SECRET=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
    
    # Update .env file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" .env
    else
        # Linux
        sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" .env
    fi
    
    print_status "JWT secret generated and updated in .env"
}

# Pull required Docker images
pull_images() {
    print_info "Pulling required Docker images..."
    
    docker pull mysql:8.0
    docker pull nginx:alpine
    docker pull redis:7-alpine
    docker pull cirrusci/flutter:stable
    docker pull golang:1.21-alpine
    
    print_status "Docker images pulled"
}

# Build custom images
build_images() {
    print_info "Building custom Docker images..."
    
    # Build backend image
    docker build -t health-pal-backend ./health_pal_backend/
    
    # Build frontend web image
    docker build -f ./health_pal_frontend/Dockerfile.web -t health-pal-frontend-web ./health_pal_frontend/
    
    print_status "Custom images built"
}

# Test Docker setup
test_setup() {
    print_info "Testing Docker setup..."
    
    # Start services
    docker-compose up -d mysql
    
    # Wait for MySQL to be ready
    print_info "Waiting for MySQL to be ready..."
    sleep 30
    
    # Check if MySQL is responding
    if docker-compose exec mysql mysqladmin ping -h localhost --silent; then
        print_status "MySQL is ready"
    else
        print_error "MySQL failed to start properly"
        exit 1
    fi
    
    # Stop test services
    docker-compose down
    
    print_status "Docker setup test completed"
}

# Main setup function
main() {
    echo "Starting Health Pal setup..."
    echo ""
    
    # Check prerequisites
    check_docker
    check_docker_compose
    check_make
    
    echo ""
    
    # Setup environment
    setup_env_files
    create_directories
    generate_jwt_secret
    
    echo ""
    
    # Docker setup
    pull_images
    build_images
    test_setup
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Review and update .env files with your configuration"
    echo "2. Add your Gemini API key to .env file"
    echo "3. Configure email settings in .env file"
    echo "4. Run 'make dev' or 'docker-compose up -d' to start the application"
    echo ""
    echo "Access points after starting:"
    echo "📱 Frontend: http://localhost:3000"
    echo "🔧 Backend: http://localhost:8080"
    echo "📚 API Docs: http://localhost:8080/swagger/index.html"
    echo ""
    echo "For more commands, run 'make help'"
}

# Run main function
main