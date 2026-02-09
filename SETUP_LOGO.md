# 🚀 Quick Start: Setup Your Couple App Logo

## Step 1: Save Your Logo Image

**IMPORTANT:** Save your couple logo image (the one with the cute blue and pink heart characters) as:

```
assets/images/couple_logo_original.png
```

Just drag and drop the image file into the `assets/images/` folder in your project.

## Step 2: Install Pillow (Image Processing Library)

```bash
pip3 install Pillow
```

## Step 3: Process Your Image (Crop White Borders)

```bash
python3 crop_app_icon.py assets/images/couple_logo_original.png
```

This will automatically:
- ✂️ Crop all white borders from your image
- 📐 Center the content perfectly
- 🎨 Create 3 optimized icon files:
  - `app_icon.png` (1024x1024)
  - `app_icon_foreground.png` (1024x1024) 
  - `notification_icon.png` (192x192)

## Step 4: Install Flutter Dependencies

```bash
flutter pub get
```

## Step 5: Generate All Platform Icons

```bash
flutter pub run flutter_launcher_icons
```

This generates icons for:
- ✅ Android (all densities + adaptive icons)
- ✅ iOS (all required sizes)
- ✅ Notification icons

## Step 6: Clean Build & Test

```bash
flutter clean
flutter run
```

## ✨ Done!

Your app will now show:
- 📱 "Couple App" as the app name
- 💕 Your cute couple logo as the icon
- 🔔 Proper notification icons

---

## 📝 What Changed

1. **App Name**: Set to "Couple App" on both Android and iOS
2. **App Icon**: Your couple logo (properly cropped)
3. **Adaptive Icons**: Android 8.0+ will show your logo in different shapes
4. **Notification Icons**: Optimized for notification display

## 🐛 Troubleshooting

**Icons not updating?**
1. Uninstall the app from your device/emulator
2. Run `flutter clean`
3. Run `flutter run` again

**Pillow installation fails?**
Try: `pip3 install --user Pillow`

For more details, see `APP_ICON_SETUP.md`
