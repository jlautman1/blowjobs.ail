#!/bin/bash
set -e

echo "🚀 Starting Netlify build for Flutter web..."

# Get the directory where this script is located (frontend directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 Working directory: $(pwd)"

# Install Flutter
echo "📦 Installing Flutter..."
FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.0}"
FLUTTER_SDK_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_SDK_DIR" ]; then
  echo "Downloading Flutter SDK..."
  cd $HOME
  git clone --depth 1 --branch $FLUTTER_VERSION https://github.com/flutter/flutter.git
fi

# Add Flutter to PATH
export PATH="$FLUTTER_SDK_DIR/bin:$PATH"

# Verify Flutter installation
echo "✅ Flutter installed:"
flutter --version

# Enable web support (this is global, doesn't need to be in project dir)
flutter config --enable-web

# Return to frontend directory for Flutter commands
cd "$SCRIPT_DIR"
echo "📁 Back in project directory: $(pwd)"

# Verify we're in the right place
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: pubspec.yaml not found in $(pwd)"
  exit 1
fi

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build web
echo "🏗️  Building Flutter web app..."
flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend-production.up.railway.app/api/v1

echo "✅ Build complete!"

