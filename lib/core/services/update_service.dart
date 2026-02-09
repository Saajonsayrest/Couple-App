import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
// import 'package:upgrader/upgrader.dart'; // We will use Upgrader widget directly in UI

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  /// Checks for native Android updates using in_app_update
  Future<void> checkForAndroidUpdate() async {
    if (!Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          // Perform immediate update for critical updates (optional choice)
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Perform flexible update
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate(); // Prompt user to restart
        }
      }
    } catch (e) {
      debugPrint("Error checking for Android update: $e");
      // Fallback or ignore
    }
  }
}
