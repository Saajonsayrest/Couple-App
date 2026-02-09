#!/bin/bash

echo "🔧 Fixing Project Permissions..."

# 1. Fix Flutter SDK Permissions (Critical)
echo "   -> Granting access to Flutter SDK..."
# Try to find flutter path
FLUTTER_PATH=$(which flutter)
if [ -z "$FLUTTER_PATH" ]; then
    # Fallback to the path seen in error logs
    FLUTTER_PATH="/opt/homebrew/share/flutter"
else
    # Resolve symlink if needed, but usually the cache is in the sdk root
    # If 'which flutter' returns bin/flutter, the sdk root is one level up
    FLUTTER_BIN_DIR=$(dirname "$FLUTTER_PATH")
    FLUTTER_SDK_DIR=$(dirname "$FLUTTER_BIN_DIR")
    FLUTTER_PATH="$FLUTTER_SDK_DIR"
fi

if [ -d "$FLUTTER_PATH" ]; then
    echo "      Found Flutter at: $FLUTTER_PATH"
    echo "      Please enter your password if prompted (to fix permissions):"
    sudo chown -R $(whoami) "$FLUTTER_PATH"
else
    echo "      ⚠️ Could not auto-detect Flutter SDK path. Please fix permissions manually."
fi


# 2. Fix Local Project Build Permissions
echo "   -> Fixing local build folder permissions..."
sudo chown -R $(whoami) .


# 3. Clean Project
echo "   -> Cleaning project..."
rm -rf build
rm -rf android/.gradle

echo "✅ Permissions Fixed! You can now build the app."
echo "   Try running 'flutter run' or use Android Studio."
