@echo off
REM Health Pal - Podman Build Script for Windows
REM This script provides easy commands to build and run Health Pal with Podman

setlocal enabledelayedexpansion

if "%1"=="" (
    echo.
    echo 🏥 Health Pal - Podman Build Script
    echo.
    echo Usage: build-podman.bat [command]
    echo.
    echo Available commands:
    echo   dev          - Start development environment
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
    echo 🚀 Starting Health Pal development environment with Podman...
    podman-compose -f docker-compose.podman.yml up -d
    echo.
    echo ✅ Podman development environment started!
    echo 📱 Frontend: http://localhost:3000
    echo 🔧 Backend API: http://localhost:8080
    echo 📚 API Docs: http://localhost:8080/swagger/index.html
    echo 🗄️  Database: localhost:3306
    goto :eof
)

if "%1"=="build-all" (
    echo 🔨 Building all platforms with Podman...
    call %0 build-apk
    call %0 build-web
    call %0 build-ios
    echo.
    echo ✅ All Podman builds completed!
    echo 📱 APK Build: http://localhost:8091
    echo 🍎 iOS Build: http://localhost:8092
    echo 🌐 Web Build: http://localhost:8093
    goto :eof
)

if "%1"=="build-apk" (
    echo 🔨 Building Android APK with Podman...
    podman build -f health_pal_frontend/Dockerfile.apk -t health-pal-apk-podman ./health_pal_frontend
    podman run -d -p 8091:80 --name health-pal-apk-podman health-pal-apk-podman
    echo ✅ Podman APK build completed!
    goto :eof
)

if "%1"=="build-web" (
    echo 🔨 Building Web application with Podman...
    podman build -f health_pal_frontend/Dockerfile.web -t health-pal-web-podman ./health_pal_frontend
    podman run -d -p 8093:80 --name health-pal-web-podman health-pal-web-podman
    echo ✅ Podman Web build completed!
    goto :eof
)

if "%1"=="build-ios" (
    echo 🔨 Building iOS information with Podman...
    podman build -f health_pal_frontend/Dockerfile.ios -t health-pal-ios-podman ./health_pal_frontend
    podman run -d -p 8092:80 --name health-pal-ios-podman health-pal-ios-podman
    echo ✅ Podman iOS build info ready!
    goto :eof
)

if "%1"=="logs" (
    echo 📋 Viewing Podman logs...
    podman-compose -f docker-compose.podman.yml logs -f
    goto :eof
)

if "%1"=="stop" (
    echo 🛑 Stopping all Podman services...
    podman-compose -f docker-compose.podman.yml down
    podman stop health-pal-apk-podman health-pal-web-podman health-pal-ios-podman 2>nul
    podman rm health-pal-apk-podman health-pal-web-podman health-pal-ios-podman 2>nul
    echo ✅ All Podman services stopped!
    goto :eof
)

if "%1"=="clean" (
    echo 🧹 Cleaning up Podman containers and volumes...
    podman-compose -f docker-compose.podman.yml down -v
    podman stop health-pal-apk-podman health-pal-web-podman health-pal-ios-podman 2>nul
    podman rm health-pal-apk-podman health-pal-web-podman health-pal-ios-podman 2>nul
    podman system prune -f
    echo ✅ Podman cleanup completed!
    goto :eof
)

if "%1"=="help" (
    call %0
    goto :eof
)

echo ❌ Unknown command: %1
echo Run 'build-podman.bat help' for available commands.