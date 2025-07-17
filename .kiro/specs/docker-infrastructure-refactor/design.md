# Design Document

## Overview

This design document outlines the approach for consolidating and simplifying the Health Pal Docker infrastructure. The current setup has multiple duplicate files and complex configurations that need to be streamlined into a clean, maintainable structure.

## Architecture

### Current State Analysis

**Existing Docker Files:**
- `health_pal_backend/Dockerfile` (original)
- `health_pal_backend/Dockerfile.podman` (duplicate)
- `health_pal_frontend/Dockerfile.web` (original)
- `health_pal_frontend/Dockerfile.web.podman` (duplicate)
- `health_pal_frontend/Dockerfile.apk` (mobile build)
- `health_pal_frontend/Dockerfile.ios` (mobile build)

**Existing Compose Files:**
- `docker-compose.yml` (development)
- `docker-compose.prod.yml` (production)
- `docker-compose.build.yml` (builds)
- `docker-compose.podman.yml` (podman duplicate)
- `docker-compose.build.podman.yml` (podman build duplicate)

**Existing Scripts:**
- `setup.sh` (Linux/macOS)
- `setup.bat` (Windows)
- `setup-podman.sh` (Podman Linux/macOS)
- `test-build-podman-all.bat` (Podman Windows)

### Target State Design

**Consolidated Docker Files:**
- `health_pal_backend/Dockerfile` (single, runtime-agnostic)
- `health_pal_frontend/Dockerfile.web` (single, runtime-agnostic)
- `health_pal_frontend/Dockerfile.apk` (mobile build)
- `health_pal_frontend/Dockerfile.ios` (mobile build)

**Consolidated Compose Files:**
- `docker-compose.yml` (main configuration with profiles)
- `docker-compose.override.yml` (development overrides)

**Simplified Scripts:**
- `setup.sh` (cross-platform setup)
- `setup.bat` (Windows setup)

## Components and Interfaces

### 1. Unified Dockerfiles

#### Backend Dockerfile
- **Purpose**: Single Dockerfile for Go backend that works with both Docker and Podman
- **Features**: Multi-stage build, security best practices, health checks
- **Runtime Detection**: Uses environment variables to handle runtime differences

#### Frontend Web Dockerfile
- **Purpose**: Single Dockerfile for Flutter web that works with both runtimes
- **Features**: Optimized Nginx configuration, static asset serving
- **Flexibility**: Configurable via environment variables

#### Mobile Build Dockerfiles
- **Purpose**: Specialized builds for APK and iOS
- **Approach**: Keep separate as they have different requirements
- **Optimization**: Shared base layers where possible

### 2. Docker Compose Profiles

#### Profile Structure
```yaml
services:
  # Core services (always included)
  mysql:
    # Database configuration
  
  backend:
    # Backend API
    profiles: ["dev", "prod", "build"]
  
  frontend-web:
    # Web frontend
    profiles: ["dev", "prod", "web-build"]
  
  # Build services (only for builds)
  build-apk:
    profiles: ["build", "apk-build"]
  
  build-ios:
    profiles: ["build", "ios-build"]
```

#### Profile Usage
- `docker-compose up` - Default development
- `docker-compose --profile prod up` - Production
- `docker-compose --profile build up` - All builds
- `docker-compose --profile apk-build up` - APK only

### 3. Environment Configuration

#### Runtime Detection
```bash
# Environment variable to choose runtime
CONTAINER_RUNTIME=docker  # or podman
```

#### Service Configuration
```yaml
# Use environment variables for runtime-specific settings
environment:
  - RUNTIME=${CONTAINER_RUNTIME:-docker}
```

### 4. Makefile Integration

#### Unified Commands
```makefile
# Detect runtime and use appropriate commands
RUNTIME ?= docker
COMPOSE_CMD = $(RUNTIME)-compose

dev:
	$(COMPOSE_CMD) up -d

build-all:
	$(COMPOSE_CMD) --profile build up -d
```

## Data Models

### Configuration Structure

#### Environment Variables
```bash
# Runtime Configuration
CONTAINER_RUNTIME=docker|podman
COMPOSE_FILE=docker-compose.yml
COMPOSE_PROFILES=dev|prod|build

# Application Configuration
DB_HOST=mysql
DB_PORT=3306
API_PORT=8080
WEB_PORT=3000

# Build Configuration
BUILD_APK_PORT=8081
BUILD_IOS_PORT=8082
BUILD_WEB_PORT=8083
```

#### Service Dependencies
```yaml
# Dependency mapping
backend:
  depends_on:
    - mysql
  
frontend-web:
  depends_on:
    - backend
  
nginx:
  depends_on:
    - backend
    - frontend-web
```

## Error Handling

### Build Error Resolution

#### Missing Dependencies
- **Problem**: Go build fails due to missing handlers
- **Solution**: Fix import paths and ensure all referenced handlers exist
- **Implementation**: Update routes.go to match available handlers

#### Runtime Compatibility
- **Problem**: Podman-specific issues with user permissions
- **Solution**: Use compatible base images and proper user management
- **Implementation**: Unified Dockerfile with conditional user setup

#### Port Conflicts
- **Problem**: Multiple services trying to use same ports
- **Solution**: Use environment variables for port configuration
- **Implementation**: Configurable port mapping in compose files

### Deployment Error Handling

#### Health Check Failures
- **Detection**: Container health check endpoints
- **Response**: Automatic restart policies
- **Logging**: Structured error logging for debugging

#### Network Issues
- **Detection**: Service connectivity checks
- **Response**: Retry mechanisms and fallback configurations
- **Monitoring**: Network health monitoring

## Testing Strategy

### Build Testing

#### Automated Build Verification
```bash
# Test all builds work
make test-builds

# Test specific runtime
CONTAINER_RUNTIME=podman make test-builds
```

#### Integration Testing
- **Service Connectivity**: Verify all services can communicate
- **Health Endpoints**: Test all health check endpoints respond
- **Build Artifacts**: Verify build outputs are correct

### Compatibility Testing

#### Runtime Testing
- **Docker**: Test all configurations work with Docker
- **Podman**: Test all configurations work with Podman
- **Cross-Platform**: Test on Windows, macOS, and Linux

#### Profile Testing
- **Development**: Test dev profile brings up correct services
- **Production**: Test prod profile has proper security and scaling
- **Build**: Test build profiles generate correct artifacts

### Performance Testing

#### Build Performance
- **Layer Caching**: Verify Docker layer caching works effectively
- **Build Time**: Measure and optimize build times
- **Image Size**: Optimize final image sizes

#### Runtime Performance
- **Startup Time**: Measure service startup times
- **Resource Usage**: Monitor CPU and memory usage
- **Scaling**: Test horizontal scaling capabilities

## Implementation Plan

### Phase 1: Consolidate Dockerfiles
1. Remove duplicate Podman-specific Dockerfiles
2. Update main Dockerfiles to be runtime-agnostic
3. Fix missing dependencies and build errors
4. Test builds work with both Docker and Podman

### Phase 2: Consolidate Compose Files
1. Create unified docker-compose.yml with profiles
2. Remove duplicate Podman compose files
3. Create docker-compose.override.yml for development
4. Update environment variable handling

### Phase 3: Simplify Scripts
1. Remove duplicate setup scripts
2. Update remaining scripts to detect and use appropriate runtime
3. Update Makefile to use runtime detection
4. Test all scripts work correctly

### Phase 4: Documentation and Testing
1. Update README with simplified instructions
2. Create comprehensive testing suite
3. Document troubleshooting steps
4. Verify all functionality works as expected

## Security Considerations

### Container Security
- **Non-root Users**: All containers run as non-root users
- **Minimal Images**: Use minimal base images (Alpine Linux)
- **Security Scanning**: Regular vulnerability scanning of images
- **Secrets Management**: Proper handling of sensitive configuration

### Network Security
- **Internal Networks**: Services communicate over internal Docker networks
- **Port Exposure**: Only necessary ports exposed to host
- **TLS/SSL**: HTTPS configuration for production deployments
- **Rate Limiting**: API rate limiting and DDoS protection

### Build Security
- **Dependency Scanning**: Scan dependencies for vulnerabilities
- **Image Signing**: Sign container images for integrity
- **Build Isolation**: Isolated build environments
- **Artifact Verification**: Verify build artifact integrity