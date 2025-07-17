# Health Pal - Docker Infrastructure

This document provides comprehensive instructions for running Health Pal using Docker containers with optimized builds for multiple platforms.

## 🏗️ Architecture Overview

### Backend (Go)
- **Multi-stage build** with Alpine Linux for minimal image size (~15MB)
- **Non-root user** for security
- **Health checks** and graceful shutdown
- **Optimized binary** with static linking

### Frontend (Flutter)
- **Multi-platform builds**: APK, Web, iOS info
- **Separate Dockerfiles** for each platform
- **Nginx serving** for production builds
- **Development hot-reload** support

### Database (MySQL)
- **Persistent volumes** for data
- **Health checks** and initialization scripts
- **Environment-based configuration**

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM available
- 10GB free disk space

### 1. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
# Update database passwords, JWT secrets, etc.
```

### 2. Development Environment
```bash
# Using Docker
make dev
# OR
build.bat dev

# Using Podman
make dev-podman
# OR
build-podman.bat dev
```

### 3. Access Services
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **API Documentation**: http://localhost:8080/swagger/index.html
- **Database**: localhost:3306

## 📱 Building for Multiple Platforms

### Build All Platforms
```bash
# Docker
make build-all
build.bat build-all

# Podman
make build-all-podman
build-podman.bat build-all
```

### Individual Platform Builds

#### Android APK
```bash
# Docker
make build-apk
build.bat build-apk

# Podman
make build-apk-podman
build-podman.bat build-apk
```
- **Output**: http://localhost:8081 (Docker) or http://localhost:8091 (Podman)
- **Files**: Multiple APK files for different architectures
- **Size**: ~50MB per APK

#### Web Application
```bash
# Docker
make build-web
build.bat build-web

# Podman
make build-web-podman
build-podman.bat build-web
```
- **Output**: http://localhost:8083 (Docker) or http://localhost:8093 (Podman)
- **Features**: Progressive Web App with offline support
- **Size**: ~10MB total

#### iOS Information
```bash
# Docker
make build-ios
build.bat build-ios

# Podman
make build-ios-podman
build-podman.bat build-ios
```
- **Output**: http://localhost:8082 (Docker) or http://localhost:8092 (Podman)
- **Note**: Actual iOS builds require macOS and Xcode

## 🏭 Production Deployment

### Production Environment
```bash
# Set production environment variables
cp .env.example .env
# Edit .env with production values

# Start production services
make prod
```

### Production Features
- **Nginx reverse proxy** with rate limiting
- **SSL/TLS support** (configure certificates)
- **Security headers** and CORS protection
- **Gzip compression** for static assets
- **Health monitoring** endpoints

## 🔧 Configuration

### Environment Variables

#### Database Configuration
```env
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=health_pal
MYSQL_USER=health_pal_user
MYSQL_PASSWORD=secure_password
```

#### Backend Configuration
```env
JWT_SECRET=your_32_character_secret_key
GOOGLE_CLIENT_ID=your_google_oauth_client_id
```

#### Email Configuration
```env
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
EMAIL_FROM=your_email@gmail.com
```

### Docker Compose Files

- **docker-compose.yml**: Development environment
- **docker-compose.prod.yml**: Production environment
- **docker-compose.build.yml**: Multi-platform builds
- **docker-compose.podman.yml**: Podman development

## 📊 Monitoring and Maintenance

### Health Checks
```bash
# Check service status
make status
docker-compose ps

# View logs
make logs
docker-compose logs -f

# Health endpoints
curl http://localhost:8080/health  # Backend
curl http://localhost/health       # Production
```

### Cleanup
```bash
# Clean containers and volumes
make clean
build.bat clean

# Complete cleanup (including images)
make clean-all
```

## 🐛 Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check port usage
netstat -an | findstr :8080
netstat -an | findstr :3000

# Stop conflicting services
docker stop $(docker ps -q)
```

#### Memory Issues
```bash
# Check Docker memory usage
docker stats

# Increase Docker memory limit (Docker Desktop)
# Settings > Resources > Memory > 4GB+
```

#### Build Failures
```bash
# Clear Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache
```

### Flutter Build Issues

#### Android SDK License
```bash
# Accept licenses manually
docker run -it health-pal-frontend flutter doctor --android-licenses
```

#### Web Build Errors
```bash
# Enable web support
flutter config --enable-web
flutter clean
flutter pub get
```

## 📈 Performance Optimization

### Backend Optimizations
- **Multi-stage builds** reduce image size by 90%
- **Static binary compilation** eliminates runtime dependencies
- **Alpine Linux base** provides minimal attack surface
- **Non-root execution** enhances security

### Frontend Optimizations
- **Split APK builds** for different architectures
- **Web renderer optimization** for better performance
- **Nginx compression** reduces transfer size
- **Asset caching** improves load times

### Database Optimizations
- **Persistent volumes** prevent data loss
- **Health checks** ensure availability
- **Connection pooling** in Go backend
- **Indexed queries** for better performance

## 🔒 Security Considerations

### Container Security
- **Non-root users** in all containers
- **Minimal base images** (Alpine Linux)
- **Security headers** in Nginx
- **Rate limiting** for API endpoints

### Network Security
- **Internal networks** for service communication
- **Exposed ports** only where necessary
- **CORS configuration** for web security
- **SSL/TLS termination** at proxy level

### Data Security
- **Environment variables** for secrets
- **Volume encryption** for sensitive data
- **JWT token security** with proper secrets
- **Database access control**

## 📚 Additional Resources

### Documentation
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Flutter Docker Guide](https://flutter.dev/docs/deployment/docker)
- [Go Docker Optimization](https://docs.docker.com/language/golang/)

### Monitoring Tools
- **Docker Stats**: `docker stats`
- **Container Logs**: `docker logs <container>`
- **Health Checks**: Built into compose files

### Development Tools
- **Hot Reload**: Enabled in development mode
- **Debug Mode**: Available through IDE integration
- **API Testing**: Swagger UI at `/swagger/index.html`

## 🤝 Contributing

When contributing to the Docker infrastructure:

1. **Test all platforms** before submitting
2. **Update documentation** for new features
3. **Maintain backward compatibility**
4. **Follow security best practices**
5. **Optimize for size and performance**

## 📝 Changelog

### Version 1.0.0
- Initial Docker infrastructure
- Multi-platform Flutter builds
- Production-ready configuration
- Comprehensive documentation
- Security hardening
- Performance optimization