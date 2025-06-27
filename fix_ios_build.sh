#!/bin/bash

# Ensure this script exits on any error
set -e

echo "🔧 Setting up rbenv (if installed)..."
if command -v rbenv &> /dev/null; then
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
  source ~/.bash_profile
else
  echo "⚠️  rbenv not found. Skipping Ruby version setup."
fi

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "📦 Getting Flutter packages..."
flutter pub get

echo "🧹 Cleaning CocoaPods..."
cd ios
rm -rf Pods Podfile.lock Runner.xcworkspace

echo "📄 Checking for missing Info.plist permissions..."
PLIST_FILE="Runner/Info.plist"
if ! grep -q "NSCameraUsageDescription" "$PLIST_FILE"; then
  echo "➕ Adding missing NSCameraUsageDescription..."
  /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'Camera access is needed to scan receipts.'" "$PLIST_FILE"
fi

if ! grep -q "NSMicrophoneUsageDescription" "$PLIST_FILE"; then
  echo "➕ Adding missing NSMicrophoneUsageDescription..."
  /usr/libexec/PlistBuddy -c "Add :NSMicrophoneUsageDescription string 'Microphone access is required by the camera plugin.'" "$PLIST_FILE"
fi

echo "📦 Re-installing CocoaPods..."
pod install

cd ..

echo "🔍 Listing connected devices..."
flutter devices

echo "🚀 Running Flutter app..."
flutter run
