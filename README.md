# 🏥 Health Pal - Multi-Platform Health Tracking Application

A comprehensive health tracking application built with Flutter frontend and Go backend, featuring AI-powered nutrition analysis, step tracking, water intake monitoring, and personalized health plans.

## 🚀 Features

### 📱 Multi-Platform Support
- **Android APK** - Native Android application
- **iOS App** - iOS application (requires macOS for real builds)
- **Web App** - Progressive Web Application
- **Responsive Design** - Works on all screen sizes

### 🎨 Modern UI/UX
- Material Design 3 implementation
- Health-focused color palette and gradients
- Animated components and smooth transitions
- Intuitive navigation and user flow
- Dark/light theme support ready

### 🏃‍♂️ Health Tracking
- **Step Tracking** - Daily step counting and history
- **Water Intake** - Hydration monitoring with goals
- **Sitting Time** - Sedentary behavior tracking
- **Food Analysis** - AI-powered food photo analysis
- **Health Score** - Comprehensive health metrics

### 🤖 AI-Powered Features
- Food photo analysis with Gemini AI
- Personalized health recommendations
- Automated nutrition tracking
- Smart reminders and notifications

### 🔧 Technical Features
- RESTful API with Swagger documentation
- JWT authentication and authorization
- File upload and storage
- Database migrations
- Health checks and monitoring
- Rate limiting and security

## 🏗️ Architecture

```
Health Pal/
├── health_pal_backend/     # Go/Gin backend API
├── health_pal_frontend/    # Flutter multi-platform app
├── nginx/                  # Load balancer configuration
├── migration/              # Database migrations
├── build-dashboard/        # Build monitoring dashboard
└── docker-compose files   # Container orchestration
```

## 📦 Building for External Access

Health Pal supports building applications that can be accessed outside of Docker containers, perfect for distributing APK files, web builds, and other artifacts.

### 🔨 Build Commands

**Windows (using build.bat):**
```bash
# Build Android APK for external access
build.bat apk

# Build all platforms
build.bat all

# Build web application
build.bat web

# Clean all builds
build.bat clean
```

**Linux/macOS (using Makefile):**
```bash
# Quick APK build for external access
make apk

# Build all platforms
make build-all

# Build specific platforms
make build-apk
make build-web
make build-ios
```

### 📱 Accessing Build Artifacts

After building, your artifacts will be available in these locations:

- **APK Files**: `./builds/apk/` - Ready for Android installation
- **Web Files**: `./builds/web/` - Deploy to any web server
- **iOS Info**: `./builds/ios/` - Build information and requirements

### 🌐 Build Servers

The build process also starts local servers for easy access:

- **APK Downloads**: http://localhost:8081
- **Web Application**: http://localhost:8083
- **iOS Information**: http://localhost:8082
- **Build Dashboard**: http://localhost:8084

### 📋 Example Workflow

1. **Build APK for distribution:**
   ```bash
   build.bat apk
   # APK files will be in ./builds/apk/
   ```

2. **Share APK with users:**
   - Copy files from `./builds/apk/` to your distribution method
   - Or direct users to http://localhost:8081 for direct download

3. **Deploy web version:**
   ```bash
   build.bat web
   # Copy ./builds/web/ contents to your web server
   ```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Make (optional, for easier commands)

### 1. Setup Environment
```bash
# Clone the repository
git clone <repository-url>
cd health-pal

# Setup environment files
make setup
# or manually copy .env.example to .env and configure
```

### 2. Start Development Environment
```bash
# Start all services
make dev

# Or using docker-compose directly
docker-compose up -d
```

### 3. Access Applications
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **API Documentation**: http://localhost:8080/swagger/index.html
- **Database**: localhost:3306

## 🔨 Building Applications

### Build All Platforms
```bash
# Build Android APK, iOS, and Web
make build-all

# Access build artifacts
# APK Download: http://localhost:8081
# iOS Info: http://localhost:8082
# Web App: http://localhost:8083
# Build Dashboard: http://localhost:8084
```

### Individual Builds
```bash
# Android APK only
make build-apk

# iOS simulation only
make build-ios

# Web application only
make build-web
```

## 🚀 Production Deployment

### Start Production Environment
```bash
# Production setup with load balancing
make prod

# Application available at http://localhost
```

### Production Features
- Nginx load balancer with SSL/TLS ready
- Health checks for all services
- Rate limiting and security headers
- Redis caching support
- Container resource limits
- Automated scaling ready

## 📊 Available Commands

```bash
# Development
make dev          # Start development environment
make dev-logs     # View development logs
make dev-stop     # Stop development environment

# Production
make prod         # Start production environment
make prod-logs    # View production logs
make prod-stop    # Stop production environment

# Building
make build-all    # Build all platforms
make build-apk    # Build Android APK
make build-ios    # Build iOS simulation
make build-web    # Build Web application

# Database
make db-migrate   # Run database migrations
make db-seed      # Seed database with sample data
make db-reset     # Reset database

# Testing
make test         # Run all tests
make test-backend # Run backend tests
make test-frontend # Run frontend tests

# Maintenance
make clean        # Clean containers and volumes
make clean-all    # Clean everything including images
make health       # Check system health
make status       # Show container status
```

## 🔧 Configuration

### Environment Variables
Key configuration options in `.env`:

```bash
# Database
DB_HOST=mysql
DB_NAME=health_pal
DB_USER=health_pal_user
DB_PASSWORD=health_pal_password

# JWT Secret (change in production!)
JWT_SECRET=your-super-secret-jwt-key

# Gemini AI
GEMINI_API_KEY=your-gemini-api-key

# Email Notifications
SMTP_HOST=smtp.gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

## 📱 Mobile App Features

### Android APK
- Native Android performance
- Offline capability ready
- Push notifications support
- Camera and gallery integration
- Health APIs integration ready

### iOS App
- Native iOS performance (requires macOS to build)
- HealthKit integration ready
- App Store deployment ready
- iOS-specific UI adaptations

### Web App
- Progressive Web App (PWA)
- Offline support with service workers
- Responsive design for all devices
- Browser push notifications
- Installable on desktop and mobile

## 🎨 UI/UX Highlights

### Modern Design System
- **Colors**: Health-focused green and blue palette
- **Typography**: Clean, readable font hierarchy
- **Spacing**: Consistent 8px grid system
- **Animations**: Smooth micro-interactions
- **Accessibility**: WCAG compliant design

### Key Components
- **HealthCard**: Animated cards with progress indicators
- **ModernButton**: Multiple styles with loading states
- **StatCard**: Clean metric display cards
- **SectionHeader**: Consistent page structure

### User Experience
- **Onboarding**: Smooth user registration flow
- **Dashboard**: Personalized health overview
- **Quick Actions**: Easy access to common tasks
- **Progress Tracking**: Visual progress indicators
- **AI Insights**: Smart health recommendations

## 🔒 Security Features

- JWT-based authentication
- Rate limiting on API endpoints
- Input validation and sanitization
- CORS configuration
- Security headers (HSTS, CSP, etc.)
- File upload restrictions
- SQL injection prevention

## 📈 Monitoring & Health Checks

### Health Endpoints
- `/health` - Application health status
- Container health checks
- Database connectivity monitoring
- API response time tracking

### Logging
- Structured JSON logging
- Request/response logging
- Error tracking and alerting
- Performance metrics

## 🧪 Testing

### Backend Testing
```bash
cd health_pal_backend
go test ./...
```

### Frontend Testing
```bash
cd health_pal_frontend
flutter test
```

### Integration Testing
```bash
make test  # Run all tests
```

## 🚀 Deployment Options

### Docker Compose (Recommended)
- Easy local development
- Production-ready setup
- Automatic service discovery
- Volume persistence

### Kubernetes (Advanced)
- Horizontal scaling
- Rolling updates
- Service mesh ready
- Cloud provider integration

### Cloud Platforms
- **AWS**: ECS, EKS, or Elastic Beanstalk
- **Google Cloud**: GKE or Cloud Run
- **Azure**: AKS or Container Instances
- **DigitalOcean**: App Platform or Kubernetes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the documentation in `/docs`
- Review the API documentation at `/swagger`
- Open an issue on GitHub
- Check the troubleshooting guide

## 🎯 Roadmap

### Phase 1 (Current)
- ✅ Multi-platform builds
- ✅ Modern UI/UX
- ✅ Docker infrastructure
- ✅ Basic health tracking

### Phase 2 (Next)
- [ ] Real-time notifications
- [ ] Offline support
- [ ] Data visualization
- [ ] Health API integrations

### Phase 3 (Future)
- [ ] Social features
- [ ] Advanced AI insights
- [ ] Wearable device integration
- [ ] Telemedicine features

---

**Built with ❤️ for better health tracking**