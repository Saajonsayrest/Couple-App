import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
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
          _updateHomeWidget(profiles[0], profiles[1]);
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
    _updateHomeWidget(me, partner);

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

  void _updateHomeWidget(UserProfile me, UserProfile partner) {
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

    HomeWidget.saveWidgetData<String>('name1', name1);
    HomeWidget.saveWidgetData<String>('name2', name2);
    HomeWidget.saveWidgetData<String>('initial1', initial1);
    HomeWidget.saveWidgetData<String>('initial2', initial2);
    HomeWidget.saveWidgetData<String>('days', days.toString());
    HomeWidget.saveWidgetData<int>(
      'startDate',
      normalizedStart.millisecondsSinceEpoch,
    );
    HomeWidget.updateWidget(name: 'CoupleWidget', androidName: 'CoupleWidget');
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
    HomeWidget.updateWidget(name: 'CoupleWidget', androidName: 'CoupleWidget');
  }
}
