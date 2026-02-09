import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super(AppPalettes.defaultTheme) {
    _loadTheme();
  }

  void _loadTheme() {
    // Box should be open from main.dart, load synchronously to prevent flash
    if (Hive.isBoxOpen(AppConstants.settingsBox)) {
      final box = Hive.box(AppConstants.settingsBox);
      state = box.get('themeId', defaultValue: AppPalettes.defaultTheme);
    }
  }

  Future<void> setTheme(String themeId) async {
    if (AppPalettes.palettes.containsKey(themeId)) {
      state = themeId;
      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put('themeId', themeId);
    }
  }
}
