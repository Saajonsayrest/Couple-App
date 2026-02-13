# iOS Widget Troubleshooting Guide

## Issue: Widget Not Showing in iOS Widget Gallery

### Quick Fixes to Try:

#### 1. **Complete Clean Build**
```bash
# Clean everything
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..

# Rebuild
./setup.sh ios-release
```

#### 2. **Verify Widget is Installed**
After running the app:
- Long press on home screen
- Tap the "+" button in top left
- Search for "Couple" or scroll to find your app
- You should see two widgets:
  - **Couple Widget** (Medium size - shows both profiles)
  - **Days Widget** (Small size - shows days count)

#### 3. **Force Reinstall**
Sometimes iOS caches the old widget. To fix:
1. Delete the app completely from your iPhone
2. Restart your iPhone
3. Run `./setup.sh ios-release` again
4. Try adding the widget

#### 4. **Check Build Logs**
When you run the app, check the Xcode output for:
```
Installing and launching...
```
This should install BOTH the main app AND the widget extension.

#### 5. **Verify in Settings → Widget Debug**
1. Open the app
2. Go to Settings → Widget Debug
3. Tap "Force Widget Update"
4. Check console logs for:
   ```
   📱 Updating widget data:
      Name1: [your name]
      Name2: [partner name]
   ✅ Widget data saved, updating widgets...
   ✅ Widgets updated successfully
   ```

### Common Issues:

**Problem**: Widget shows in gallery but is blank/white
- **Solution**: Go to Settings → Widget Debug → Force Widget Update

**Problem**: Widget not in gallery at all
- **Solution**: Delete app, restart phone, reinstall

**Problem**: Widget shows old data
- **Solution**: Remove widget from home screen, re-add it

**Problem**: Build fails with signing errors
- **Solution**: Check that both Runner and CoupleWidgetExtension have the same Team ID (8GUPPQYLWH)

### Debug Commands:

Check if widget extension is built:
```bash
ls -la ios/build/ios/Release-iphoneos/
# Should see: CoupleWidgetExtension.appex
```

View console logs while running:
```bash
./setup.sh ios-release
# Watch for any errors related to CoupleWidgetExtension
```

### Still Not Working?

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select "CoupleWidgetExtension" scheme
3. Build and run directly from Xcode
4. Check for any build errors specific to the widget

### Expected Behavior:

✅ After installing the app, you should see:
- "Couple Widget" in the widget gallery (Medium size)
- When added, shows: avatars, names, days count
- Updates automatically when you change profile data

✅ Widget should show:
- Pink/teal colored avatar circles (or photos if uploaded)
- Names in the center
- Large days count
- "Days Together" label
