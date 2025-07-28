# Multi-stage Docker build for Flutter XHS API Server

# Stage 1: Build the Flutter application
FROM --platform=linux/amd64 dart:stable AS build

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade

# Copy the application source
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Generate JSON serialization code
RUN flutter packages pub run build_runner build --delete-conflicting-outputs

# Build the application
RUN flutter build linux --release

# Stage 2: Runtime environment with Python
FROM --platform=linux/amd64 ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    gnupg \
    unzip \
    libglib2.0-0 \
    libnss3-dev \
    libgconf-2-4 \
    libxss1 \
    libappindicator1 \
    fonts-liberation \
    libasound2-dev \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxkbcommon0 \
    libatspi2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt
RUN pip3 install playwright
RUN playwright install chromium
RUN playwright install-deps chromium

# Copy the XHS Python SDK
WORKDIR /app
COPY ../xhs ./xhs/
COPY ../requirements.txt ./
COPY ../setup.py ./

# Install XHS SDK
RUN pip3 install -e .

# Copy the built Flutter application
COPY --from=build /app/build/linux/x64/release/bundle ./flutter_app/

# Copy additional files
COPY --from=build /app/lib ./lib/

# Set environment variables
ENV PORT=8080
ENV PYTHON_PATH=python3
ENV XHS_MODULE_PATH=/app

# Expose the port
EXPOSE 8080

# Create a script to run the application
RUN echo '#!/bin/bash\n\
export DISPLAY=:99\n\
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &\n\
cd /app/flutter_app && ./xhs_flutter_api\n\
' > /app/start.sh && chmod +x /app/start.sh

# Install Xvfb for headless browser
RUN apt-get update && apt-get install -y xvfb && rm -rf /var/lib/apt/lists/*

CMD ["/app/start.sh"]