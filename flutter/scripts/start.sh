#!/bin/bash

# XHS Flutter API Server Startup Script

set -e

echo "🚀 Starting XHS Flutter API Server..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Set environment variables
export PORT="${PORT:-8080}"
export PYTHON_PATH="${PYTHON_PATH:-python3}"
export XHS_MODULE_PATH="${XHS_MODULE_PATH:-../}"

echo "📋 Configuration:"
echo "   - Port: $PORT"
echo "   - Python Path: $PYTHON_PATH"
echo "   - XHS Module Path: $XHS_MODULE_PATH"

# Install dependencies if needed
if [ ! -d ".dart_tool/package_config.json" ] || [ "pubspec.yaml" -nt ".dart_tool/package_config.json" ]; then
    echo "📦 Installing Flutter dependencies..."
    flutter pub get
fi

# Generate JSON serialization code if needed
if [ ! -f "lib/src/models/xhs_models.g.dart" ] || [ "lib/src/models/xhs_models.dart" -nt "lib/src/models/xhs_models.g.dart" ]; then
    echo "🔧 Generating JSON serialization code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Check Python dependencies
echo "🔍 Checking Python dependencies..."
$PYTHON_PATH -c "
import sys
import importlib.util

required_packages = ['requests', 'lxml', 'playwright']
missing_packages = []

for package in required_packages:
    if importlib.util.find_spec(package) is None:
        missing_packages.append(package)

if missing_packages:
    print(f'❌ Missing Python packages: {missing_packages}')
    print('Please install them with: pip install ' + ' '.join(missing_packages))
    sys.exit(1)
else:
    print('✅ All Python dependencies are available')
"

# Check if XHS module is available
echo "🔍 Checking XHS module..."
$PYTHON_PATH -c "
import sys
import os
sys.path.append('$XHS_MODULE_PATH')
try:
    import xhs
    print('✅ XHS module is available')
except ImportError as e:
    print(f'❌ XHS module not found: {e}')
    print('Please ensure the XHS Python SDK is in the correct path: $XHS_MODULE_PATH')
    sys.exit(1)
"

# Start the server
echo "🌟 Starting Flutter API server on port $PORT..."
flutter run --release --dart-define=PORT=$PORT --dart-define=PYTHON_PATH=$PYTHON_PATH --dart-define=XHS_MODULE_PATH=$XHS_MODULE_PATH