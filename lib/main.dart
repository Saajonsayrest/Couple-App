import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'services/notification_service.dart';

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeType),
      routerConfig: router,
    );
  }
}
