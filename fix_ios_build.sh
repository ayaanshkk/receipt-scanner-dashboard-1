#!/bin/bash

echo "🧹 Cleaning Flutter project..."
flutter clean

echo "📦 Getting Flutter packages..."
flutter pub get

echo "🧹 Cleaning CocoaPods..."
cd ios
rm -rf Pods Podfile.lock Runner.xcworkspace

echo "📦 Installing CocoaPods..."
pod install
cd ..

echo "🚀 Running Flutter app..."
flutter run
