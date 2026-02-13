import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path/path.dart' as p;
import '../core/constants.dart';
import '../data/models/user_profile.dart';
import '../services/notification_service.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, List<UserProfile>>((ref) {
      return ProfileNotifier();
    });

class ProfileNotifier extends StateNotifier<List<UserProfile>> {
  ProfileNotifier() : super([]) {
    _loadProfiles();
  }

  void _loadProfiles() {
    if (Hive.isBoxOpen(AppConstants.userBox)) {
      final box = Hive.box<UserProfile>(AppConstants.userBox);
      if (box.isNotEmpty) {
        final profiles = box.values.toList();
        state = profiles;
        if (profiles.length >= 2) {
          _updateHomeWidget(profiles[0], profiles[1]).then((_) {});
        }
      }
    }
  }

  Future<void> updateProfiles({
    required UserProfile me,
    required UserProfile partner,
  }) async {
    final box = Hive.box<UserProfile>(AppConstants.userBox);

    // Save to Hive
    await box.put(0, me);
    await box.put(1, partner);

    // Update local state to trigger UI changes
    state = [me, partner];

    // Update Home Widget
    await _updateHomeWidget(me, partner);

    // Schedule Special Events
    try {
      final notifService = NotificationService();

      // Anniversary
      if (me.relationshipStartDate != null) {
        await notifService.scheduleAnnualEvent(
          id: 1001,
          title: 'Happy Anniversary! ❤️',
          body: 'Another year of love and happiness together! 🥂',
          date: me.relationshipStartDate!,
        );
      }

      final partnerName = partner.nickname.isNotEmpty
          ? partner.nickname
          : partner.name;

      // Partner Birthday
      await notifService.scheduleAnnualEvent(
        id: 1002,
        title: 'Happy Birthday $partnerName! 🎂',
        body: "Today is $partnerName's special day! Make it amazing! 🎉",
        date: partner.birthday,
      );

      // My Birthday
      await notifService.scheduleAnnualEvent(
        id: 1003,
        title: 'Happy Birthday to You! 🎂',
        body: "It's your special day! Hope $partnerName spoils you! 🎁",
        date: me.birthday,
      );
    } catch (e) {
      // In release mode, notification scheduling might fail due to system settings
      // We don't want to block the onboarding/update process because of this
      print('Failed to schedule annual notifications: $e');
    }
  }

  Future<void> _updateHomeWidget(UserProfile me, UserProfile partner) async {
    final startDate = me.relationshipStartDate ?? DateTime.now();
    // Normalize to midnight for consistent day counting
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final days = DateTime.now().difference(normalizedStart).inDays + 1;

    final name1 = me.nickname.isNotEmpty ? me.nickname : me.name;
    final name2 = partner.nickname.isNotEmpty ? partner.nickname : partner.name;

    // Get first letter for initials
    final initial1 = name1.isNotEmpty ? name1[0].toUpperCase() : '?';
    final initial2 = name2.isNotEmpty ? name2[0].toUpperCase() : '?';

    // Debug logging
    print('📱 Updating widget data:');
    print('   Name1: $name1, Name2: $name2');
    print('   Initial1: $initial1, Initial2: $initial2');
    print('   Days: $days');
    print('   StartDate: ${normalizedStart.millisecondsSinceEpoch}');
    print('   Avatar1: ${me.avatarPath}');
    print('   Avatar2: ${partner.avatarPath}');

    // Save all data to widget (await each call)
    await HomeWidget.saveWidgetData<String>('name1', name1);
    await HomeWidget.saveWidgetData<String>('name2', name2);
    await HomeWidget.saveWidgetData<String>('initial1', initial1);
    await HomeWidget.saveWidgetData<String>('initial2', initial2);
    await HomeWidget.saveWidgetData<String>('days', days.toString());
    await HomeWidget.saveWidgetData<int>(
      'startDate',
      normalizedStart.millisecondsSinceEpoch,
    );

    // Save avatar paths for widget images (await to ensure copy completes)
    await _saveAvatar(me.avatarPath, 'avatar1Path');
    await _saveAvatar(partner.avatarPath, 'avatar2Path');

    print('✅ Widget data saved, updating widgets...');

    // Update both widgets
    await HomeWidget.updateWidget(
      name: 'CoupleWidget',
      androidName: 'CoupleWidget',
    );
    await HomeWidget.updateWidget(
      name: 'DaysWidget',
      androidName: 'DaysWidget',
    );

    print('✅ Widgets updated successfully');
  }

  Future<void> _saveAvatar(String? path, String key) async {
    print('   🖼️ Saving avatar for $key: $path');

    if (path == null || path.isEmpty) {
      await HomeWidget.saveWidgetData<String>(key, '');
      print('   ⚠️ No avatar path for $key');
      return;
    }

    String finalPath = path;

    if (Platform.isIOS) {
      try {
        print('   📱 iOS: Copying image to App Group...');
        const channel = MethodChannel('com.sajon.couple_app/app_group');
        final String? appGroupPath = await channel.invokeMethod(
          'getAppGroupPath',
        );

        if (appGroupPath != null) {
          print('   📁 App Group path: $appGroupPath');
          final fileName = p.basename(path);
          final newPath = p.join(appGroupPath, fileName);

          // Check if source file exists
          if (await File(path).exists()) {
            await File(path).copy(newPath);
            finalPath = fileName; // Save only the filename for the iOS widget
            print('   ✅ Image copied to: $newPath');
            print('   💾 Saving filename to widget: $fileName');
          } else {
            print('   ❌ Source file does not exist: $path');
          }
        } else {
          print('   ❌ App Group path is null');
        }
      } catch (e) {
        print('   ❌ Failed to copy image to app group: $e');
      }
    }

    await HomeWidget.saveWidgetData<String>(key, finalPath);
    print('   ✅ Avatar saved for $key: $finalPath');
  }

  Future<void> reset() async {
    final box = Hive.box<UserProfile>(AppConstants.userBox);
    await box.clear();
    state = [];

    // Clear Widget Data
    HomeWidget.saveWidgetData('name1', null);
    HomeWidget.saveWidgetData('name2', null);
    HomeWidget.saveWidgetData('initial1', null);
    HomeWidget.saveWidgetData('initial2', null);
    HomeWidget.saveWidgetData('days', null);
    HomeWidget.saveWidgetData('startDate', null);
    HomeWidget.saveWidgetData('avatar1Path', null);
    HomeWidget.saveWidgetData('avatar2Path', null);
    // Update both widgets
    HomeWidget.updateWidget(name: 'CoupleWidget', androidName: 'CoupleWidget');
    HomeWidget.updateWidget(name: 'DaysWidget', androidName: 'DaysWidget');
  }
}
