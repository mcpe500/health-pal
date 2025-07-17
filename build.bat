@echo off
REM Health Pal - Docker Build Script for Windows
REM This script provides easy commands to build and run Health Pal with Docker

setlocal enabledelayedexpansion

if "%1"=="" (
    echo.
    echo 🏥 Health Pal - Docker Build Script
    echo.
    echo Usage: build.bat [command]
    echo.
    echo Available commands:
    echo   dev          - Start development environment
    echo   prod         - Start production environment
    echo   build-all    - Build all platforms ^(APK, Web, iOS^)
    echo   build-apk    - Build Android APK only
    echo   build-web    - Build Web app only
    echo   build-ios    - Build iOS info only
    echo   clean        - Clean up containers and volumes
    echo   logs         - View logs
    echo   stop         - Stop all services
    echo   help         - Show this help
    echo.
    goto :eof
)

if "%1"=="dev" (
    echo 🚀 Starting Health Pal development environment...
    docker-compose up -d
    echo.
    echo ✅ Development environment started!
    echo 📱 Frontend: http://localhost:3000
    echo 🔧 Backend API: http://localhost:8080
    echo 📚 API Docs: http://localhost:8080/swagger/index.html
    echo 🗄️  Database: localhost:3306
    goto :eof
)

if "%1"=="prod" (
    echo 🚀 Starting Health Pal production environment...
    docker-compose -f docker-compose.prod.yml up -d
    echo.
    echo ✅ Production environment started!
    echo 🌐 Application: http://localhost
    goto :eof
)

if "%1"=="build-all" (
    echo 🔨 Building all platforms...
    docker-compose -f docker-compose.build.yml up -d
    echo.
    echo ✅ All builds started!
    echo 📱 APK Build: http://localhost:8081
    echo 🍎 iOS Build: http://localhost:8082
    echo 🌐 Web Build: http://localhost:8083
    echo 📊 Build Dashboard: http://localhost:8084
    goto :eof
)

if "%1"=="build-apk" (
    echo 🔨 Building Android APK...
    docker build -f health_pal_frontend/Dockerfile.apk -t health-pal-apk ./health_pal_frontend
    docker run -d -p 8081:80 --name health-pal-apk-serve health-pal-apk
    echo.
    echo ✅ APK build completed!
    echo 📱 Download: http://localhost:8081
    goto :eof
)

if "%1"=="build-web" (
    echo 🔨 Building Web application...
    docker build -f health_pal_frontend/Dockerfile.web -t health-pal-web ./health_pal_frontend
    docker run -d -p 8083:80 --name health-pal-web-serve health-pal-web
    echo.
    echo ✅ Web build completed!
    echo 🌐 Launch: http://localhost:8083
    goto :eof
)

if "%1"=="build-ios" (
    echo 🔨 Building iOS information...
    docker build -f health_pal_frontend/Dockerfile.ios -t health-pal-ios ./health_pal_frontend
    docker run -d -p 8082:80 --name health-pal-ios-serve health-pal-ios
    echo.
    echo ✅ iOS build info ready!
    echo 🍎 Info: http://localhost:8082
    goto :eof
)

if "%1"=="logs" (
    echo 📋 Viewing logs...
    docker-compose logs -f
    goto :eof
)

if "%1"=="stop" (
    echo 🛑 Stopping all services...
    docker-compose down
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.build.yml down
    docker stop health-pal-apk-serve health-pal-web-serve health-pal-ios-serve 2>nul
    docker rm health-pal-apk-serve health-pal-web-serve health-pal-ios-serve 2>nul
    echo ✅ All services stopped!
    goto :eof
)

if "%1"=="clean" (
    echo 🧹 Cleaning up containers and volumes...
    docker-compose down -v
    docker-compose -f docker-compose.prod.yml down -v
    docker-compose -f docker-compose.build.yml down -v
    docker stop health-pal-apk-serve health-pal-web-serve health-pal-ios-serve 2>nul
    docker rm health-pal-apk-serve health-pal-web-serve health-pal-ios-serve 2>nul
    docker system prune -f
    echo ✅ Cleanup completed!
    goto :eof
)

if "%1"=="help" (
    call %0
    goto :eof
)

echo ❌ Unknown command: %1
echo Run 'build.bat help' for available commands.