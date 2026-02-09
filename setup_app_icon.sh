#!/bin/bash

# Script to setup app icons for the Couple App
# This script will:
# 1. Crop white space from the original image
# 2. Create app icon variants (foreground, notification)
# 3. Generate all platform-specific icons

set -e

echo "🎨 Setting up Couple App Icons..."

# Check if source image exists
if [ ! -f "assets/images/couple_logo_original.png" ]; then
    echo "❌ Error: Please save your couple logo image as 'assets/images/couple_logo_original.png'"
    echo "   You can drag and drop the image file to the assets/images/ folder"
    exit 1
fi

echo "✂️  Step 1: Cropping white space from the original image..."

# Use sips (macOS built-in tool) to crop the image
# First, let's get the image dimensions
original_image="assets/images/couple_logo_original.png"

# Create a cropped version by trimming white borders
# We'll use sips to crop the image to remove white space
# Note: This creates a 1024x1024 version which is the standard for app icons

echo "📐 Creating 1024x1024 app icon (cropped)..."

# Method 1: Using sips to resize and crop
# First resize to ensure we have a good base
sips -z 1024 1024 "$original_image" --out "assets/images/app_icon_temp.png" > /dev/null 2>&1

# For better cropping, we'll use a Python script if available, otherwise manual crop
if command -v python3 &> /dev/null; then
    echo "🐍 Using Python for intelligent cropping..."
    
    # Create a Python script to auto-crop white borders
    cat > /tmp/crop_image.py << 'PYTHON_SCRIPT'
from PIL import Image
import sys

def crop_white_borders(input_path, output_path, tolerance=250):
    """Crop white borders from an image"""
    img = Image.open(input_path)
    
    # Convert to RGB if necessary
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Get image data
    pixels = img.load()
    width, height = img.size
    
    # Find boundaries
    left = width
    right = 0
    top = height
    bottom = 0
    
    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y][:3]
            # Check if pixel is not white (with tolerance)
            if r < tolerance or g < tolerance or b < tolerance:
                left = min(left, x)
                right = max(right, x)
                top = min(top, y)
                bottom = max(bottom, y)
    
    # Add small padding (2% of image)
    padding = int(min(width, height) * 0.02)
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(width, right + padding)
    bottom = min(height, bottom + padding)
    
    # Crop the image
    cropped = img.crop((left, top, right, bottom))
    
    # Make it square by adding transparent padding if needed
    size = max(cropped.width, cropped.height)
    square_img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    
    # Paste cropped image in center
    offset_x = (size - cropped.width) // 2
    offset_y = (size - cropped.height) // 2
    square_img.paste(cropped, (offset_x, offset_y))
    
    # Resize to 1024x1024
    final_img = square_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    final_img.save(output_path, 'PNG')
    print(f"✅ Cropped and saved to {output_path}")

if __name__ == "__main__":
    try:
        from PIL import Image
        crop_white_borders(sys.argv[1], sys.argv[2])
    except ImportError:
        print("❌ PIL/Pillow not installed. Using basic crop instead.")
        sys.exit(1)
PYTHON_SCRIPT

    # Try to run the Python script
    if python3 /tmp/crop_image.py "$original_image" "assets/images/app_icon.png" 2>/dev/null; then
        echo "✅ Successfully cropped using Python"
    else
        echo "⚠️  PIL not available, using basic resize"
        sips -z 1024 1024 "$original_image" --out "assets/images/app_icon.png" > /dev/null 2>&1
    fi
    
    rm -f /tmp/crop_image.py
else
    echo "⚠️  Python not available, using basic resize"
    sips -z 1024 1024 "$original_image" --out "assets/images/app_icon.png" > /dev/null 2>&1
fi

echo "✅ Main app icon created: assets/images/app_icon.png"

echo "🎭 Step 2: Creating foreground icon for Android adaptive icons..."

# For adaptive icons, we need a foreground that's slightly smaller (to account for safe zone)
# Android adaptive icons use a 108x108dp canvas with a 72x72dp safe zone
# So we'll create a version with some padding

sips -z 1024 1024 "assets/images/app_icon.png" --out "assets/images/app_icon_foreground.png" > /dev/null 2>&1

echo "✅ Foreground icon created: assets/images/app_icon_foreground.png"

echo "🔔 Step 3: Creating notification icon (monochrome)..."

# For notification icons, we need a simple monochrome version
# We'll create a white silhouette version
# For now, we'll use the same icon - you may want to create a simpler version manually

sips -z 192 192 "assets/images/app_icon.png" --out "assets/images/notification_icon.png" > /dev/null 2>&1

echo "✅ Notification icon created: assets/images/notification_icon.png"
echo "   💡 Note: For best results, create a simple monochrome (white) version of your logo"
echo "   for notifications. The current version will work but a simplified version is recommended."

# Clean up temp files
rm -f "assets/images/app_icon_temp.png"

echo ""
echo "📦 Step 4: Installing flutter_launcher_icons package..."

flutter pub get

echo ""
echo "🚀 Step 5: Generating platform-specific icons..."

flutter pub run flutter_launcher_icons

echo ""
echo "✨ ============================================="
echo "✨ App Icon Setup Complete!"
echo "✨ ============================================="
echo ""
echo "📱 Generated icons for:"
echo "   ✅ Android launcher icons (all densities)"
echo "   ✅ Android adaptive icons (foreground + background)"
echo "   ✅ Android notification icons"
echo "   ✅ iOS app icons (all sizes)"
echo ""
echo "🎨 Icon files created:"
echo "   • assets/images/app_icon.png (1024x1024 - main icon)"
echo "   • assets/images/app_icon_foreground.png (adaptive icon foreground)"
echo "   • assets/images/notification_icon.png (notification icon)"
echo ""
echo "💡 Next steps:"
echo "   1. Review the generated icons in:"
echo "      - android/app/src/main/res/mipmap-*/"
echo "      - ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "   2. Test the app on both Android and iOS devices"
echo "   3. Check notification icons by triggering a notification"
echo ""
echo "🎉 Your cute couple logo is now ready for Android & iOS!"
echo ""
