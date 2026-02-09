#!/bin/bash

# Simple App Icon Setup using macOS sips (no Python/Pillow required)
# This script crops and prepares your couple logo for the app

set -e

echo "🎨 Couple App Icon Setup (macOS sips version)"
echo "=============================================="
echo ""

# Check if source image exists
if [ ! -f "assets/images/couple_logo_original.png" ]; then
    echo "❌ Error: Please save your couple logo as 'assets/images/couple_logo_original.png'"
    echo ""
    echo "📝 Instructions:"
    echo "   1. Locate your couple logo image file"
    echo "   2. Drag it into the assets/images/ folder"
    echo "   3. Rename it to: couple_logo_original.png"
    echo "   4. Run this script again"
    echo ""
    exit 1
fi

echo "✅ Found logo image"
echo ""

# Create the icon files using sips
echo "🔄 Processing images with sips..."
echo ""

# Main app icon (1024x1024)
echo "1️⃣  Creating app_icon.png (1024x1024)..."
sips -z 1024 1024 "assets/images/couple_logo_original.png" --out "assets/images/app_icon.png" > /dev/null 2>&1
echo "   ✅ Created"

# Foreground for adaptive icon (1024x1024)
echo "2️⃣  Creating app_icon_foreground.png (1024x1024)..."
sips -z 1024 1024 "assets/images/couple_logo_original.png" --out "assets/images/app_icon_foreground.png" > /dev/null 2>&1
echo "   ✅ Created"

# Notification icon (192x192)
echo "3️⃣  Creating notification_icon.png (192x192)..."
sips -z 192 192 "assets/images/couple_logo_original.png" --out "assets/images/notification_icon.png" > /dev/null 2>&1
echo "   ✅ Created"

echo ""
echo "📦 Installing Flutter dependencies..."
cd /Users/sajon/StudioProjects/couple_app
flutter pub get

echo ""
echo "🚀 Generating platform-specific icons..."
flutter pub run flutter_launcher_icons

echo ""
echo "✨ ============================================="
echo "✨ SUCCESS! App Icon Setup Complete!"
echo "✨ ============================================="
echo ""
echo "📱 Your app now has:"
echo "   ✅ App name: 'Couple App'"
echo "   ✅ App icon: Your cute couple logo"
echo "   ✅ Android icons (all densities)"
echo "   ✅ iOS icons (all sizes)"
echo "   ✅ Notification icons"
echo ""
echo "🎯 Next steps:"
echo "   1. Run: flutter clean"
echo "   2. Run: flutter run"
echo "   3. Check the app icon on your device!"
echo ""
echo "💡 Note: If you want better cropping (to remove white borders),"
echo "   you can manually crop the image before saving it as"
echo "   couple_logo_original.png, or install Pillow and use"
echo "   the crop_app_icon.py script."
echo ""
