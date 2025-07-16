@echo off
setlocal enabledelayedexpansion

REM Health Pal Setup Script for Windows
REM This script sets up the Health Pal application for development

echo 🏥 Health Pal Setup Script
echo ==========================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/windows/
    pause
    exit /b 1
)
echo ✅ Docker is installed

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    echo Visit: https://docs.docker.com/compose/install/
    pause
    exit /b 1
)
echo ✅ Docker Compose is installed

echo.
echo ℹ️  Setting up environment files...

REM Create main .env file
if not exist .env (
    copy .env.example .env >nul
    echo ✅ Created main .env file
) else (
    echo ⚠️  .env file already exists, skipping
)

REM Create backend .env file
if not exist health_pal_backend\.env (
    copy health_pal_backend\.env.example health_pal_backend\.env >nul
    echo ✅ Created backend .env file
) else (
    echo ⚠️  Backend .env file already exists, skipping
)

REM Create frontend .env file
if not exist health_pal_frontend\.env (
    echo API_BASE_URL=http://localhost:8080 > health_pal_frontend\.env
    echo ✅ Created frontend .env file
) else (
    echo ⚠️  Frontend .env file already exists, skipping
)

echo.
echo ℹ️  Creating necessary directories...

if not exist nginx\ssl mkdir nginx\ssl
if not exist nginx\logs mkdir nginx\logs
if not exist mysql\conf.d mkdir mysql\conf.d
if not exist health_pal_backend\uploads mkdir health_pal_backend\uploads

echo ✅ Directories created

echo.
echo ℹ️  Pulling required Docker images...

docker pull mysql:8.0
docker pull nginx:alpine
docker pull redis:7-alpine
docker pull cirrusci/flutter:stable
docker pull golang:1.21-alpine

echo ✅ Docker images pulled

echo.
echo ℹ️  Building custom Docker images...

docker build -t health-pal-backend ./health_pal_backend/
docker build -f ./health_pal_frontend/Dockerfile.web -t health-pal-frontend-web ./health_pal_frontend/

echo ✅ Custom images built

echo.
echo ℹ️  Testing Docker setup...

REM Start MySQL service
docker-compose up -d mysql

echo ℹ️  Waiting for MySQL to be ready...
timeout /t 30 /nobreak >nul

REM Check if MySQL is responding
docker-compose exec mysql mysqladmin ping -h localhost --silent >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ MySQL is ready
) else (
    echo ❌ MySQL failed to start properly
    docker-compose down
    pause
    exit /b 1
)

REM Stop test services
docker-compose down

echo ✅ Docker setup test completed

echo.
echo 🎉 Setup completed successfully!
echo.
echo Next steps:
echo 1. Review and update .env files with your configuration
echo 2. Add your Gemini API key to .env file
echo 3. Configure email settings in .env file
echo 4. Run 'docker-compose up -d' to start the application
echo.
echo Access points after starting:
echo 📱 Frontend: http://localhost:3000
echo 🔧 Backend: http://localhost:8080
echo 📚 API Docs: http://localhost:8080/swagger/index.html
echo.
echo For more information, check the README.md file
echo.
pause