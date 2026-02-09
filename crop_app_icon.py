#!/usr/bin/env python3
"""
Intelligent Image Cropper for App Icons
This script crops white borders from images and prepares them for use as app icons.
"""

import sys
import os

try:
    from PIL import Image, ImageChops
except ImportError:
    print("❌ Error: Pillow library is required.")
    print("   Install it with: pip3 install Pillow")
    sys.exit(1)


def trim_white_borders(image, tolerance=250):
    """
    Remove white borders from an image.
    
    Args:
        image: PIL Image object
        tolerance: RGB value threshold (0-255). Pixels with all RGB values 
                  above this are considered white.
    
    Returns:
        Cropped PIL Image object
    """
    # Convert to RGB if necessary
    if image.mode == 'RGBA':
        # Create a white background
        background = Image.new('RGB', image.size, (255, 255, 255))
        background.paste(image, mask=image.split()[3])  # Use alpha channel as mask
        image = background
    elif image.mode != 'RGB':
        image = image.convert('RGB')
    
    # Get image data
    pixels = image.load()
    width, height = image.size
    
    # Find boundaries of non-white content
    left = width
    right = 0
    top = height
    bottom = 0
    
    found_content = False
    
    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y][:3]
            # Check if pixel is not white (with tolerance)
            if r < tolerance or g < tolerance or b < tolerance:
                found_content = True
                left = min(left, x)
                right = max(right, x)
                top = min(top, y)
                bottom = max(bottom, y)
    
    if not found_content:
        print("⚠️  Warning: No non-white content found. Using original image.")
        return image
    
    # Add small padding (2% of image size)
    padding = int(min(width, height) * 0.02)
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(width - 1, right + padding)
    bottom = min(height - 1, bottom + padding)
    
    print(f"   Cropping from ({left}, {top}) to ({right}, {bottom})")
    print(f"   Original size: {width}x{height}")
    print(f"   Cropped size: {right-left+1}x{bottom-top+1}")
    
    # Crop the image
    cropped = image.crop((left, top, right + 1, bottom + 1))
    
    return cropped


def make_square_with_padding(image, background_color=(255, 255, 255, 0)):
    """
    Make an image square by adding transparent or colored padding.
    
    Args:
        image: PIL Image object
        background_color: RGBA tuple for background
    
    Returns:
        Square PIL Image object
    """
    width, height = image.size
    size = max(width, height)
    
    # Create a square image with transparent background
    square_img = Image.new('RGBA', (size, size), background_color)
    
    # Calculate position to center the image
    offset_x = (size - width) // 2
    offset_y = (size - height) // 2
    
    # Convert original to RGBA if needed
    if image.mode != 'RGBA':
        image = image.convert('RGBA')
    
    # Paste the image in the center
    square_img.paste(image, (offset_x, offset_y), image)
    
    return square_img


def create_app_icon(input_path, output_path, size=1024):
    """
    Create an app icon by cropping white borders and resizing.
    
    Args:
        input_path: Path to input image
        output_path: Path to save output image
        size: Output size (default 1024x1024)
    """
    print(f"📖 Reading image: {input_path}")
    
    # Open the image
    image = Image.open(input_path)
    
    print(f"   Original mode: {image.mode}, size: {image.size}")
    
    # Trim white borders
    print("✂️  Trimming white borders...")
    cropped = trim_white_borders(image, tolerance=250)
    
    # Make it square with transparent padding
    print("📐 Making square with centered content...")
    square = make_square_with_padding(cropped)
    
    # Resize to target size with high-quality resampling
    print(f"🔄 Resizing to {size}x{size}...")
    final = square.resize((size, size), Image.Resampling.LANCZOS)
    
    # Save the result
    print(f"💾 Saving to: {output_path}")
    final.save(output_path, 'PNG', optimize=True)
    
    print(f"✅ Successfully created app icon!")


def create_notification_icon(input_path, output_path, size=192):
    """
    Create a notification icon (simplified, smaller version).
    
    Args:
        input_path: Path to input image
        output_path: Path to save output image
        size: Output size (default 192x192)
    """
    print(f"📖 Reading image for notification icon: {input_path}")
    
    image = Image.open(input_path)
    
    # Resize to notification icon size
    resized = image.resize((size, size), Image.Resampling.LANCZOS)
    
    # Save
    resized.save(output_path, 'PNG', optimize=True)
    
    print(f"✅ Notification icon created: {output_path}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 crop_app_icon.py <input_image>")
        print("Example: python3 crop_app_icon.py couple_logo.png")
        sys.exit(1)
    
    input_path = sys.argv[1]
    
    if not os.path.exists(input_path):
        print(f"❌ Error: File not found: {input_path}")
        sys.exit(1)
    
    # Create output directory if it doesn't exist
    output_dir = "assets/images"
    os.makedirs(output_dir, exist_ok=True)
    
    print("🎨 Couple App Icon Processor")
    print("=" * 50)
    print()
    
    # Create main app icon (1024x1024)
    print("1️⃣  Creating main app icon (1024x1024)...")
    create_app_icon(
        input_path,
        os.path.join(output_dir, "app_icon.png"),
        size=1024
    )
    print()
    
    # Create foreground for adaptive icon (same as main icon)
    print("2️⃣  Creating adaptive icon foreground (1024x1024)...")
    create_app_icon(
        input_path,
        os.path.join(output_dir, "app_icon_foreground.png"),
        size=1024
    )
    print()
    
    # Create notification icon (192x192)
    print("3️⃣  Creating notification icon (192x192)...")
    create_notification_icon(
        os.path.join(output_dir, "app_icon.png"),
        os.path.join(output_dir, "notification_icon.png"),
        size=192
    )
    print()
    
    print("=" * 50)
    print("✨ All icons created successfully!")
    print()
    print("📁 Created files:")
    print(f"   • {output_dir}/app_icon.png")
    print(f"   • {output_dir}/app_icon_foreground.png")
    print(f"   • {output_dir}/notification_icon.png")
    print()
    print("🚀 Next step: Run 'flutter pub run flutter_launcher_icons'")


if __name__ == "__main__":
    main()
