# Health Pal Application - Local Development Setup Guide

This guide provides instructions for setting up the local development environment for the Health Pal application, which consists of a Flutter frontend, a Go backend, and a Node.js testing suite.

## 1. Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **Git:** For cloning the repository.
*   **Docker & Docker Compose:** For running the MySQL database.
*   **Go:** Version 1.22 or newer (recommended).
    *   [Download Go](https://go.dev/dl/)
*   **Flutter SDK:** Version 3.22.0 or newer (compatible with Dart 3.4.0).
    *   [Install Flutter](https://flutter.dev/docs/get-started/install)
*   **Node.js:** Version 20.x or newer (LTS recommended).
    *   [Download Node.js](https://nodejs.org/en/download/)
*   **npm (Node Package Manager):** Comes with Node.js.
*   **Appium:** Global installation for E2E testing (refer to the `health_pal_testing` section).
    *   `npm install -g appium@next`
*   **Java Development Kit (JDK):** Version 11 or newer (required for Appium Android automation).
*   **Android SDK:** (Required for Flutter Android development and Appium Android automation). Set `ANDROID_HOME` environment variable.
*   **MySQL Client:** For database interaction (optional, but useful).

## 2. Repository Setup

1.  **Clone the repository:**
    ```bash
    git clone [repository_url]
    cd health-pal
    ```

## 3. Backend Setup (Go)

The backend is built with Go and uses Gin framework, GORM for MySQL, and integrates with Google Gemini API.

### 3.1. Install Go Dependencies

Navigate to the `health_pal_backend` directory and install the Go modules:

```bash
cd health_pal_backend
go mod tidy
```

### 3.2. Database Setup (MySQL with Docker Compose)

The project uses MySQL. You can set up a MySQL instance using Docker Compose.

1.  Create a `docker-compose.yml` file in the root of your project (e.g., `health-pal/docker-compose.yml`) with the following content:

    ```yaml
    version: '3.8'
    services:
      db:
        image: mysql:8.0
        container_name: health_pal_mysql
        environment:
          MYSQL_ROOT_PASSWORD: your_root_password # Change this
          MYSQL_DATABASE: health_pal_db           # Change this to your DB_NAME
          MYSQL_USER: health_pal_user             # Change this to your DB_USER
          MYSQL_PASSWORD: health_pal_password     # Change this to your DB_PASSWORD
        ports:
          - "3306:3306"
        volumes:
          - db_data:/var/lib/mysql
        healthcheck:
          test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
          timeout: 20s
          retries: 10
    volumes:
      db_data:
    ```

    **Note:** Replace `your_root_password`, `health_pal_db`, `health_pal_user`, and `health_pal_password` with your desired values. These should match the environment variables in the next step.

2.  Start the MySQL container:

    ```bash
    docker-compose up -d db
    ```

3.  Wait for the database to be healthy before proceeding. You can check its status with `docker-compose ps` or `docker-compose logs db`.

### 3.3. Environment Variables

Create a `.env` file in the `health_pal_backend` directory:

```env
DB_USER=health_pal_user
DB_PASSWORD=health_pal_password
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=health_pal_db

JWT_SECRET=your_jwt_secret_key # Change this to a strong, random string

GOOGLE_CLIENT_ID=your_google_client_id # Obtain from Google Cloud Console
GEMINI_API_KEY=your_gemini_api_key     # Obtain from Google AI Studio or Google Cloud Console

EMAIL_HOST=smtp.example.com    # e.g., smtp.gmail.com
EMAIL_PORT=587                 # e.g., 587 for TLS
EMAIL_USERNAME=your_email@example.com
EMAIL_PASSWORD=your_email_password
EMAIL_FROM=your_email@example.com
```

**Important:**
*   `DB_USER`, `DB_PASSWORD`, `DB_NAME` should match your Docker Compose setup. `DB_HOST` should be `127.0.0.1` when running Docker locally.
*   `JWT_SECRET` should be a long, random string.
*   `GOOGLE_CLIENT_ID` is required for Google OAuth.
*   `GEMINI_API_KEY` is required for AI features.
*   Email configuration is needed for OTP and reminder notifications.

### 3.4. Run Database Migrations

The project uses GORM for ORM, and migrations are handled separately (likely via a migration tool or GORM's auto-migrate feature on startup). Ensure your database schema is up-to-date. (Check `main.go` for `db.AutoMigrate` calls or look for a separate migration script/tool).

### 3.5. Run the Backend

From the `health_pal_backend` directory:

```bash
go run main.go
```

The backend should start on `http://localhost:8080`.

## 4. Frontend Setup (Flutter)

The frontend is a Flutter application.

### 4.1. Install Flutter Dependencies

Navigate to the `health_pal_frontend` directory and get the Flutter packages:

```bash
cd health_pal_frontend
flutter pub get
```

### 4.2. Environment Variables

The Flutter app uses `flutter_dotenv`. Create a `.env` file in the `health_pal_frontend` directory:

```env
MOCKDATA=true # Set to false for real backend interaction
```

### 4.3. Run the Frontend

You can run the Flutter app on an emulator, simulator, or a connected device.

```bash
flutter run
```

## 5. Testing Suite Setup (Node.js)

The testing suite uses Jest for API tests and WebdriverIO with Appium for E2E tests.

### 5.1. Install Node.js Dependencies

Navigate to the `health_pal_testing` directory and install npm packages:

```bash
cd health_pal_testing
npm install
```

**Key Dependencies:**
*   `axios`: For making HTTP requests in API tests.
*   `jest`: Testing framework for API tests.
*   `@wdio/cli`, `@wdio/appium-service`, etc.: WebdriverIO components for E2E tests.
*   `appium`, `appium-uiautomator2-driver`: Appium server and Android driver for mobile automation.

### 5.2. Run API Tests (Jest)

From the `health_pal_testing` directory:

```bash
npm test
```

### 5.3. Run E2E Tests (WebdriverIO with Appium)

**Prerequisites for E2E:**
*   An Android emulator or physical device connected and running.
*   Appium server running.
*   The Flutter app's APK built for release (e.g., `health_pal_frontend/build/app/outputs/flutter-apk/app-release.apk`).

1.  **Build Flutter APK (if not already built):**
    From `health_pal_frontend` directory:
    ```bash
    flutter build apk --release
    ```

2.  **Start Appium Server:**
    In a new terminal, from any directory (since Appium is globally installed):
    ```bash
    appium
    ```

3.  **Run WebdriverIO tests:**
    From the `health_pal_testing` directory:
    ```bash
    npm run wdio
    ```

    Ensure the `wdio.conf.ts` file has the correct `appium:deviceName` and `appium:app` path for your setup.

## 6. Common Issues and Troubleshooting

*   **Port Conflicts:** If the backend (8080) or MySQL (3306) ports are already in use, you'll need to change them in their respective configurations.
*   **Environment Variables:** Double-check that all `.env` files are correctly placed and variables are set. Restart applications after changing environment variables.
*   **Database Connection:** Ensure the MySQL container is running and healthy, and that your `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` are correct in the backend's `.env` file.
*   **Flutter Doctor:** Run `flutter doctor` to check for any Flutter-related setup issues.
*   **Appium Setup:** Verify Appium's setup by running `appium-doctor` (if installed) or checking Appium logs for errors. Ensure `ANDROID_HOME` is correctly set.
*   **Mock Tokens:** For API tests, you might need to generate valid mock Google ID tokens and JWTs if the provided ones are not sufficient or expire.