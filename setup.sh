#!/bin/bash

# ===========================
# Flutter Setup Script
# Usage:
#   ./setup.sh android   → Android only
#   ./setup.sh ios       → iOS only
#   ./setup.sh all       → Both (default)
# ===========================

TARGET=${1:-android}  # Default to 'android' if no argument provided

# --- Android Setup ---
function android_setup() {
    echo "🧹 Cleaning Android project..."
    flutter clean

    echo "📦 Getting dependencies..."
    flutter pub get

    echo "🚀 Running Android app..."
    flutter run

    echo "✅ Android setup + run done!"
}


# --- iOS Setup ---
function ios_setup() {
    echo "🧹 Cleaning iOS project..."
    flutter clean

    echo "📦 Getting dependencies..."
    flutter pub get

    echo "🍎 Installing iOS pods..."
    cd ios || exit
    pod install
    cd ..

    echo "🤖 Building iOS app..."
    flutter build ios
    open ios/Runner.xcworkspace
    echo "✅ iOS setup done!"
}

# --- Run Based on Target ---
case "$TARGET" in
    android)
        android_setup
        ;;
    ios)
        ios_setup
        ;;
    all)
        android_setup
        ios_setup
        ;;
    *)
        echo "Usage: $0 [android|ios|all]"
        exit 1
        ;;
esac

echo "🎉 All done!"



adb kill-server
adb start-server
adbwire

flutter clean
flutter pub get
flutter build apk --release
flutter build appbundle --release