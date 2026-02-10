import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'services/notification_service.dart';
import 'services/app_update_service.dart';
import 'core/globals.dart';

import 'data/models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Boxes
  await Hive.openBox(AppConstants.settingsBox);

  Hive.registerAdapter(UserProfileAdapter());
  await Hive.openBox<UserProfile>(AppConstants.userBox);
  await Hive.openBox(AppConstants.timelineBox);
  await Hive.openBox(AppConstants.remindersBox);

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final AppUpdateService _updateService = AppUpdateService();

  @override
  void initState() {
    super.initState();
    // Check for native updates (mostly Android)
    _updateService.checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final themeType = ref.watch(themeProvider);
    // router is imported globally from routes/app_router.dart

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeType),
      routerConfig: router,
      builder: (context, child) {
        // UpgradeAlert handles iOS store updates & Android fallback
        // Forcing latest version: showIgnore=false, showLater=false
        return UpgradeAlert(
          upgrader: Upgrader(
            debugLogging: false,
            // duration: const Duration(days: 0), // check immediately
          ),
          showIgnore: false,
          showLater: false,
          showReleaseNotes: true,
          dialogStyle: Platform.isIOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
