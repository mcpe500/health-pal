# Multi-stage Flutter build for multiple platforms
FROM ubuntu:22.04 AS flutter-base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    build-essential \
    libssl-dev \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Install Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip -q commandlinetools-linux-9477386_latest.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm commandlinetools-linux-9477386_latest.zip

# Set Android environment variables
ENV PATH=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

# Accept Android licenses and install required packages
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Install Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=${FLUTTER_HOME}/bin:${PATH}

RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME} && \
    flutter doctor --android-licenses && \
    flutter config --android-sdk ${ANDROID_SDK_ROOT} && \
    flutter doctor

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get Flutter dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build stage for APK
FROM flutter-base AS build-apk
RUN flutter build apk --release --split-per-abi
RUN mkdir -p /output && cp build/app/outputs/flutter-apk/*.apk /output/

# Build stage for Web
FROM flutter-base AS build-web
RUN flutter build web --release
RUN mkdir -p /output && cp -r build/web/* /output/

# Build stage for iOS (simulation only in Docker)
FROM flutter-base AS build-ios
RUN flutter build ios --release --no-codesign || true
RUN mkdir -p /output && echo "iOS build completed (simulation)" > /output/ios-build-info.txt

# Final stage for serving builds
FROM nginx:alpine AS serve

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create directories for different builds
RUN mkdir -p /usr/share/nginx/html/apk \
             /usr/share/nginx/html/web \
             /usr/share/nginx/html/ios

# Copy builds from different stages
COPY --from=build-apk /output/*.apk /usr/share/nginx/html/apk/
COPY --from=build-web /output/ /usr/share/nginx/html/web/
COPY --from=build-ios /output/ /usr/share/nginx/html/ios/

# Create index pages for each build type
RUN echo '<html><body><h1>Health Pal APK Downloads</h1><ul>' > /usr/share/nginx/html/apk/index.html && \
    for apk in /usr/share/nginx/html/apk/*.apk; do \
        filename=$(basename "$apk"); \
        echo "<li><a href=\"$filename\">$filename</a></li>" >> /usr/share/nginx/html/apk/index.html; \
    done && \
    echo '</ul></body></html>' >> /usr/share/nginx/html/apk/index.html

RUN echo '<html><body><h1>Health Pal iOS Build Info</h1><pre>' > /usr/share/nginx/html/ios/index.html && \
    cat /usr/share/nginx/html/ios/ios-build-info.txt >> /usr/share/nginx/html/ios/index.html && \
    echo '</pre><p>Note: iOS builds require macOS and Xcode for actual deployment.</p></body></html>' >> /usr/share/nginx/html/ios/index.html

# Create main index page
RUN echo '<html><body><h1>Health Pal Builds</h1><ul><li><a href="/web/">Web App</a></li><li><a href="/apk/">Android APK</a></li><li><a href="/ios/">iOS Info</a></li></ul></body></html>' > /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]