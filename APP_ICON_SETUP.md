# 🎨 App Icon Setup Guide for Couple App

This guide will help you set up your cute couple logo as the app icon for both Android and iOS, including notification icons.

## 📋 Prerequisites

1. Your couple logo image (the one with the blue and pink heart characters)
2. Python 3 with Pillow library (for intelligent cropping)

## 🚀 Quick Setup (Recommended)

### Step 1: Save Your Logo

Save your couple logo image as:
```
assets/images/couple_logo_original.png
```

You can drag and drop the image file into the `assets/images/` folder.

### Step 2: Install Pillow (if not already installed)

```bash
pip3 install Pillow
```

### Step 3: Run the Icon Processor

```bash
python3 crop_app_icon.py assets/images/couple_logo_original.png
```

This will:
- ✂️ Intelligently crop white borders from your image
- 📐 Center the content and make it square
- 🎨 Create all required icon variants:
  - `app_icon.png` (1024x1024) - Main app icon
  - `app_icon_foreground.png` (1024x1024) - For Android adaptive icons
  - `notification_icon.png` (192x192) - For notifications

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Generate Platform Icons

```bash
flutter pub run flutter_launcher_icons
```

This will automatically generate:
- ✅ Android launcher icons (all densities: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Android adaptive icons (with foreground and background)
- ✅ Android notification icons
- ✅ iOS app icons (all required sizes)

### Step 6: Test Your App

```bash
flutter run
```

Check:
1. App icon on home screen (Android & iOS)
2. App icon in app drawer (Android)
3. Notification icon when you receive a reminder notification
4. Widget icon (if applicable)

## 🛠️ Alternative: Bash Script Method

If you prefer, you can use the bash script (works on macOS):

```bash
chmod +x setup_app_icon.sh
./setup_app_icon.sh
```

This uses macOS's built-in `sips` tool for image processing.

## 📱 What Gets Generated

### Android Icons

1. **Launcher Icons** (in `android/app/src/main/res/mipmap-*/`)
   - `ic_launcher.png` - Standard launcher icon
   - Multiple densities: mdpi (48x48), hdpi (72x72), xhdpi (96x96), xxhdpi (144x144), xxxhdpi (192x192)

2. **Adaptive Icons** (in `android/app/src/main/res/mipmap-*/`)
   - `ic_launcher_foreground.png` - Foreground layer
   - Background color: White (#FFFFFF)
   - Supports Android 8.0+ dynamic shapes

3. **Notification Icons** (in `android/app/src/main/res/drawable-*/`)
   - `notification_icon.png` - Monochrome icon for notifications
   - Used by flutter_local_notifications

### iOS Icons

All required sizes in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:
- iPhone: 20x20, 29x29, 40x40, 60x60 (all @1x, @2x, @3x variants)
- iPad: 20x20, 29x29, 40x40, 76x76, 83.5x83.5
- App Store: 1024x1024

## 🎨 Icon Design Best Practices

### ✅ What Your Icon Does Right

- Cute, memorable design with the couple heart characters
- Clear visual identity
- Works well at small sizes
- Appropriate for a couple/relationship app

### 💡 Recommendations

1. **Notification Icon**: Consider creating a simplified monochrome version
   - Just the heart outline in white
   - Simpler design works better for small notification icons

2. **Adaptive Icon Safe Zone**: The current setup accounts for Android's safe zone
   - Content is centered and properly sized
   - Will look good in circle, square, rounded square, and squircle shapes

3. **Testing**: Test on different devices and Android versions
   - Android 8.0+ will show adaptive icons
   - Older versions will show standard icons

## 🔧 Customization

### Change Adaptive Icon Background Color

Edit `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  adaptive_icon_background: "#E8F4FF"  # Light blue
  # or
  adaptive_icon_background: "#FFE8F4"  # Light pink
```

Then run: `flutter pub run flutter_launcher_icons`

### Create a Custom Notification Icon

1. Create a simple white silhouette of your logo
2. Save it as `assets/images/notification_icon.png` (192x192)
3. Run: `flutter pub run flutter_launcher_icons`

## 📂 File Structure

```
couple_app/
├── assets/
│   └── images/
│       ├── couple_logo_original.png  (your original image)
│       ├── app_icon.png              (generated: 1024x1024)
│       ├── app_icon_foreground.png   (generated: 1024x1024)
│       └── notification_icon.png     (generated: 192x192)
├── android/
│   └── app/src/main/res/
│       ├── mipmap-mdpi/
│       ├── mipmap-hdpi/
│       ├── mipmap-xhdpi/
│       ├── mipmap-xxhdpi/
│       ├── mipmap-xxxhdpi/
│       └── drawable-*/
├── ios/
│   └── Runner/Assets.xcassets/AppIcon.appiconset/
├── crop_app_icon.py                  (icon processor script)
├── setup_app_icon.sh                 (alternative bash script)
└── pubspec.yaml                      (icon configuration)
```

## 🐛 Troubleshooting

### Icons not updating after generation?

1. **Clean build**:
   ```bash
   flutter clean
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

2. **Uninstall and reinstall the app**:
   - Android: Uninstall from device, then `flutter run`
   - iOS: Delete from simulator/device, then `flutter run`

### Python script fails?

Make sure Pillow is installed:
```bash
pip3 install Pillow
```

### Notification icon not showing correctly?

1. Check that the icon is monochrome (white on transparent)
2. Verify the icon path in `pubspec.yaml`
3. Regenerate: `flutter pub run flutter_launcher_icons`

### Adaptive icon looks cut off?

The safe zone for adaptive icons is 66dp out of 108dp. The script accounts for this, but if content is still cut off:
1. Reduce the size of your logo slightly
2. Add more padding in the cropping script
3. Edit `crop_app_icon.py` and increase the padding value

## 📚 Additional Resources

- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons Guide](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)

## ✨ Summary

Your cute couple logo will now appear:
- 📱 On the home screen (Android & iOS)
- 🔔 In notifications
- 📲 In the app drawer
- 🏪 In the app store (when published)
- 🎨 As an adaptive icon on Android 8.0+

Enjoy your beautifully branded couple app! 💕
