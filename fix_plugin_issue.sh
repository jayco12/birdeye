#!/bin/bash

echo "🔧 Fixing Flutter plugin issues..."

# Clean the project
echo "🧹 Cleaning Flutter project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# For iOS (if running on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Updating iOS pods..."
    cd ios
    pod install --repo-update
    cd ..
fi

echo "✅ Plugin fix complete!"
echo "📱 Now restart your app completely (not hot reload)"
echo "🔄 If still having issues, try: flutter run --no-hot"