# 🎨 Couple App Logo & Name Setup - COMPLETE GUIDE

## ✅ What's Been Done

1. **App Name Changed to "Couple App"**
   - ✅ Android: Updated in `AndroidManifest.xml`
   - ✅ iOS: Already set in `Info.plist`

2. **Icon Configuration Added**
   - ✅ Added `flutter_launcher_icons` package
   - ✅ Configured for Android & iOS
   - ✅ Set up adaptive icons for Android
   - ✅ Set up notification icons

3. **Helper Scripts Created**
   - ✅ `setup_logo_simple.sh` - Easy setup using macOS sips
   - ✅ `crop_app_icon.py` - Advanced cropping (requires Pillow)
   - ✅ Documentation files

---

## 🚀 QUICK START (Recommended)

### Step 1: Save Your Logo

**Save your couple logo image** (the cute blue & pink heart characters) as:

```
assets/images/couple_logo_original.png
```

**How to do this:**
1. Open Finder and navigate to your project folder
2. Go to `couple_app/assets/images/`
3. Drag and drop your logo image there
4. Rename it to `couple_logo_original.png`

### Step 2: Run the Setup Script

Open Terminal in your project folder and run:

```bash
./setup_logo_simple.sh
```

This will:
- ✂️ Resize your logo to proper sizes
- 🎨 Create all icon variants
- 📦 Install Flutter dependencies
- 🚀 Generate all platform icons automatically

### Step 3: Clean Build & Test

```bash
flutter clean
flutter run
```

**Uninstall the app first** from your device/emulator if it's already installed, then run the app again to see the new icon and name!

---

## 🎯 What You'll See

After completing the setup:

### On Android:
- 📱 **Home Screen**: "Couple App" with your cute couple logo
- 📲 **App Drawer**: Same icon and name
- 🔔 **Notifications**: Your logo in notifications
- 🎨 **Adaptive Icon**: Logo adapts to different shapes (circle, square, etc.) on Android 8.0+

### On iOS:
- 📱 **Home Screen**: "Couple App" with your couple logo
- 🔔 **Notifications**: Proper icon display
- 📲 **App Switcher**: Your logo

---

## 📁 Files Created

After running the setup, you'll have:

```
assets/images/
├── couple_logo_original.png    ← Your original image (you provide this)
├── app_icon.png                ← Generated: 1024x1024 main icon
├── app_icon_foreground.png     ← Generated: For Android adaptive icons
└── notification_icon.png       ← Generated: For notifications
```

Platform-specific icons are generated in:
- `android/app/src/main/res/mipmap-*/` (Android launcher icons)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (iOS app icons)

---

## 🔧 Advanced: Better Cropping (Optional)

The simple script resizes your image but doesn't crop white borders. For **perfect cropping** that removes white space:

### Option 1: Manual Crop (Easiest)
1. Open your logo in Preview or any image editor
2. Use the crop tool to remove white borders
3. Make sure the content is centered
4. Save as `couple_logo_original.png`
5. Run `./setup_logo_simple.sh`

### Option 2: Python Script (Automatic)
If you want automatic intelligent cropping:

1. Install Pillow (you may need to fix permissions first):
   ```bash
   sudo pip3 install Pillow
   ```

2. Run the Python cropping script:
   ```bash
   python3 crop_app_icon.py assets/images/couple_logo_original.png
   ```

3. Generate icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

---

## 🐛 Troubleshooting

### Icons Not Updating?

**Solution:**
1. Completely uninstall the app from your device/emulator
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run `flutter run`

### Script Says "File Not Found"?

**Solution:**
- Make sure you saved your logo as `assets/images/couple_logo_original.png`
- Check the file name is exactly correct (case-sensitive)
- Make sure the `assets/images/` folder exists

### Permission Errors?

**Solution:**
- Run the script with: `bash setup_logo_simple.sh` instead of `./setup_logo_simple.sh`
- Or make it executable: `chmod +x setup_logo_simple.sh`

### Flutter pub get fails?

**Solution:**
- Make sure you're in the project directory
- Try: `cd /Users/sajon/StudioProjects/couple_app`
- Then run the script again

---

## 📝 Technical Details

### App Name Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<application android:label="Couple App" ...>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleDisplayName</key>
<string>Couple App</string>
```

### Icon Sizes Generated

**Android:**
- mdpi: 48x48
- hdpi: 72x72
- xhdpi: 96x96
- xxhdpi: 144x144
- xxxhdpi: 192x192
- Adaptive icon: 108x108 (with foreground/background layers)

**iOS:**
- Various sizes from 20x20 to 1024x1024
- All @1x, @2x, @3x variants
- iPhone, iPad, and App Store sizes

---

## 🎉 Summary

You now have:
- ✅ App name: "Couple App" (Android & iOS)
- ✅ App icon: Your cute couple logo (properly sized)
- ✅ Notification icons: Optimized for notifications
- ✅ Adaptive icons: Android 8.0+ shape adaptation
- ✅ All platform-specific sizes: Automatically generated

**Just save your logo and run the script!** 🚀

---

## 📚 Additional Files

- `SETUP_LOGO.md` - Quick start guide
- `APP_ICON_SETUP.md` - Detailed technical documentation
- `setup_logo_simple.sh` - Simple setup script (uses sips)
- `crop_app_icon.py` - Advanced cropping script (uses Python/Pillow)
- `setup_app_icon.sh` - Alternative bash script

Choose whichever method works best for you!
