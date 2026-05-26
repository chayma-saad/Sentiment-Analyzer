# ──────────────────────────────────────────────────────────
# Stage 1: Build environment
# ──────────────────────────────────────────────────────────
FROM ubuntu:22.04 AS builder

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
ENV FLUTTER_VERSION=3.22.0
ENV FLUTTER_HOME=/flutter
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

RUN git clone \
    --depth 1 \
    --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git \
    ${FLUTTER_HOME}

# Pre-cache Flutter artifacts
RUN flutter precache --no-ios --no-macos --no-windows --no-linux --no-fuchsia

# Set working directory
WORKDIR /app

# Copy project files
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies (cached layer)
RUN flutter pub get

# Copy the rest of the source
COPY . .

# ──────────────────────────────────────────────────────────
# Stage 2: CI runner (analyze + test)
# ──────────────────────────────────────────────────────────
FROM builder AS ci

# Generate mock files
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Run static analysis
RUN flutter analyze --no-pub

# Run tests
RUN flutter test --reporter=expanded

# ──────────────────────────────────────────────────────────
# Stage 3: Android APK build
# ──────────────────────────────────────────────────────────
FROM builder AS android-build

# Install Java (required for Android builds)
RUN apt-get update && apt-get install -y openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Accept Android SDK licenses and set up SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
         -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools \
       ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

RUN flutter pub run build_runner build --delete-conflicting-outputs

RUN flutter build apk --debug

# ──────────────────────────────────────────────────────────
# Default: run CI stage
# ──────────────────────────────────────────────────────────
FROM ci AS default
CMD ["flutter", "test", "--reporter=expanded"]
