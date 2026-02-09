import 'dart:io';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/foundation.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();

  factory AppUpdateService() {
    return _instance;
  }

  AppUpdateService._internal();

  Future<void> checkForUpdate() async {
    if (Platform.isAndroid) {
      try {
        final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          if (updateInfo.immediateUpdateAllowed) {
            // Perform immediate update
            await InAppUpdate.performImmediateUpdate();
          } else if (updateInfo.flexibleUpdateAllowed) {
            // Perform flexible update
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error checking for Android update: $e');
        }
      }
    }
    // For iOS, we handle it via UpgradeAlert wrapper in main.dart
  }
}
