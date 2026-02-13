# iOS Widget & Data Reset Fixes

## Summary
Fixed two major issues:
1. **iOS Widget not showing images** - Images weren't accessible to the widget extension due to iOS sandbox restrictions
2. **Data reset not working properly** - App wasn't returning to onboarding screen after reset

## Changes Made

### 1. iOS Widget Image Fix

#### Problem
iOS apps use "sandboxing" - the widget extension cannot access files in the main app's private folder. When users selected photos, they were saved in the app's local folder, making them invisible to the widget.

#### Solution
Implemented App Group shared container for cross-process data sharing:

**File: `ios/Runner/AppDelegate.swift`**
- Added MethodChannel `com.sajon.couple_app/app_group`
- Provides the App Group container path to Flutter
- Allows the app to copy images to a shared location

**File: `lib/providers/profile_provider.dart`**
- Made `_updateHomeWidget()` async to properly await image operations
- Added `_saveAvatar()` method that:
  - On iOS: Copies images to App Group container (`group.com.sajon.coupleApp`)
  - On Android: Uses the original path
  - Saves only the filename for iOS (widget looks in App Group)
  - Saves full path for Android

**File: `ios/CoupleWidget/CoupleWidget.swift`**
- Added `synchronize()` call to force UserDefaults refresh
- Added debug logging to track data flow
- Widget now properly reads from App Group shared container

### 2. Data Reset Enhancement

**File: `lib/screens/settings/settings_screen.dart`**
- Enhanced reset dialog with clearer messaging
- Added `barrierDismissible: false` to prevent accidental dismissal
- Added theme reset to default (`sky_dreams`)
- Improved user experience with better explanation

**Behavior:**
- Clears all Hive boxes (profiles, settings, timeline, reminders)
- Cancels all notifications
- Resets theme to default
- Navigates to onboarding screen
- Router automatically prevents going back (due to empty user data)

## How to Test

### iOS Widget Images
1. Run the app: `./setup.sh ios-release`
2. Complete onboarding and select profile photos
3. Add the widget to your home screen
4. Images should now appear in the widget

### Data Reset
1. Go to Settings → Reset Data
2. Confirm the reset
3. App should return to onboarding screen
4. Cannot navigate back to main app
5. Widget should show default "Setup App" state

## Technical Notes

### App Group Configuration
Both the main app and widget extension must have:
- Entitlements file with `com.apple.security.application-groups`
- Group identifier: `group.com.sajon.coupleApp`

### Image Flow (iOS)
1. User selects image → Saved to app's Documents directory
2. Profile update triggered → `_saveAvatar()` called
3. Image copied to App Group container
4. Only filename saved to UserDefaults
5. Widget reads filename from UserDefaults
6. Widget loads image from App Group container using filename

### Why This Works
- App Group is a shared container both processes can access
- UserDefaults(suiteName:) uses the shared container
- Images are physically copied to shared location
- Widget has read access to shared container

## Files Modified
1. `ios/Runner/AppDelegate.swift` - Added MethodChannel for App Group path
2. `lib/providers/profile_provider.dart` - Image copying logic
3. `ios/CoupleWidget/CoupleWidget.swift` - Better data synchronization
4. `lib/screens/settings/settings_screen.dart` - Enhanced reset functionality
