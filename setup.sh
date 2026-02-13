#!/bin/bash

# ==============================================================================
# USAGE (Copy & Paste):
#   ./setup.sh sim             -> Clean + Get + Pods + Run on Simulator
#   ./setup.sh ios-release     -> Clean + Get + Pods + Run on Physical Phone
#   ./setup.sh android-release -> Clean + Get + Run on Android Phone
#   ./setup.sh apk             -> Clean + Get + Build APK
#   ./setup.sh ipa             -> Clean + Get + Pods + Build IPA
# ==============================================================================

# Auto-detect Physical iOS Device ID (skips simulators)
detect_ios() {
    flutter devices | grep '• ios •' | grep -v 'simulator' | head -n 1 | awk -F '•' '{print $2}' | xargs
}

# Auto-detect Simulator Device ID
detect_sim() {
    flutter devices | grep '(simulator)' | head -n 1 | awk -F '•' '{print $2}' | xargs
}

# Helpers
clean_get() { 
    echo "🧹 Cleaning and fetching packages..."
    flutter clean && flutter pub get 
}
ios_setup() { 
    clean_get
    echo "🍎 Installing iOS Pods..."
    cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
}

echo "🚀 Executing: $1"

case "$1" in
    run)             clean_get && flutter run ;;
    sim)             
        ID=$(detect_sim)
        if [ -z "$ID" ]; then
             echo "❌ ERROR: No simulator detected. Please open Simulator.app."
             exit 1
        fi
        ios_setup && flutter run -d "$ID" 
        ;;
    ios-release)     
        ID=$(detect_ios)
        if [ -z "$ID" ]; then
            echo "❌ ERROR: No physical iPhone detected. Connect via USB or ensure Wireless debugging is active."
            exit 1
        fi
        ios_setup && flutter run --release -d "$ID" 
        ;;
    android-release) clean_get && flutter run --release -d android ;;
    apk)             clean_get && flutter build apk --release ;;
    bundle)          clean_get && flutter build appbundle --release ;;
    ipa)             ios_setup && flutter build ipa --export-options-plist=ios/ExportOptions.plist ;;
    build-ios)       ios_setup && flutter build ios --release ;;
    ios)             ios_setup ;;
    clean)           clean_get ;;
    *)               echo "Usage: ./setup.sh [run|sim|ios-release|android-release|apk|bundle|ipa|build-ios|ios|clean]" ;;
esac