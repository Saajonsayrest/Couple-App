# App Auto-Update Setup Guide

## Overview
We've implemented a **Force Update** system that ensures users are always on the latest version.

- **Android**: Uses Google's native In-App Updates API (Immediate mode).
- **iOS**: Uses `upgrader` package to prompt users to update via App Store, with "Ignore" and "Later" buttons hidden.

## 1. Android Setup (Critical)

For Android auto-updates to work, you **must code sign** your app and upload it to Google Play (Internal Testing or Production).

### A. Generate Upload Keystore
Run this command in your terminal to generate a keystore file:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*   **Password**: Remember the password you set!
*   **Location**: It will save to `android/app/upload-keystore.jks`.

### B. Configure `key.properties`
Create a file named `key.properties` in `android/` directory:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=upload-keystore.jks
```
**Step to act:** *Add `key.properties` to your `.gitignore` to keep credentials safe.*

### C. Configure `build.gradle`
In `android/app/build.gradle.kts`:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true 
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}
```

### D. Testing Android Updates
1.  **Build App Bundle**: `flutter build appbundle`
2.  **Upload to Google Play Console** (Internal Testing track).
3.  **Install** the app on a device from the Play Store link.
4.  **Release a New Version**: Increment `version` in `pubspec.yaml` (e.g., `1.0.1+2`), build, and upload to the same track.
5.  **Check Update**: Open the old installed app. It should detect the update and prompt immediately.
    *   *Note: In-app updates might take a few hours to propagate even on internal tracks.*

---

## 2. iOS Setup

iOS updates work by checking the App Store version against the installed version.

1.  **App Store Connect**: Ensure your app is set up in App Store Connect.
2.  **Testing**:
    *   Set `version` in `pubspec.yaml` to a lower number (e.g., `0.9.0`) than what is live strictly for testing.
    *   Run app on Simulator/Device.
    *   The `UpgradeAlert` will appear.
    *   Since we set `showIgnore: false` and `showLater: false`, the user **must** click "Update Now" (redirects to App Store).

## 3. Maintenance

*   **To Force Updates**: Just release a new version to the stores. The app logic we added will catch it.
*   **Immediate vs Flexible (Android)**: Currently set to `IMMEDIATE` in `AppUpdateService` for mandatory updates. You can change this in `lib/services/app_update_service.dart`.

## Troubleshooting

*   **"Update not available"**: 
    *   Android: Ensure the account is in the tester list and you downloaded the app via Play Store, not `flutter run`.
    *   iOS: Ensure the App Store version is genuinely higher than the local version.
*   **UI Blocking**: The `UpgradeAlert` wraps the entire app, so it should block interaction until updated on iOS.
*   **Debug Mode**: In debug mode, Android updates often fail `checkForUpdate`. Use a release build to test properly.
