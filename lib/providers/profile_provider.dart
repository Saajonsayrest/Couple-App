import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import '../core/constants.dart';
import '../data/models/user_profile.dart';

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
        state = box.values.toList();
      }
    }
  }

  Future<void> updateProfiles({
    required UserProfile me,
    required UserProfile partner,
  }) async {
    final box = Hive.box<UserProfile>(AppConstants.userBox);

    // Save to Hive
    await box.putAt(0, me);
    await box.putAt(1, partner);

    // Update local state to trigger UI changes
    state = [me, partner];

    // Update Home Widget
    _updateHomeWidget(me, partner);
  }

  void _updateHomeWidget(UserProfile me, UserProfile partner) {
    final startDate = me.relationshipStartDate ?? DateTime.now();
    final days = DateTime.now().difference(startDate).inDays + 1;

    final name1 = me.nickname.isNotEmpty ? me.nickname : me.name;
    final name2 = partner.nickname.isNotEmpty ? partner.nickname : partner.name;

    HomeWidget.saveWidgetData<String>('name1', name1);
    HomeWidget.saveWidgetData<String>('name2', name2);
    HomeWidget.saveWidgetData<String>('days', days.toString());
    HomeWidget.saveWidgetData<int>(
      'startDate',
      startDate.millisecondsSinceEpoch,
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
    HomeWidget.saveWidgetData('days', null);
    HomeWidget.saveWidgetData('startDate', null);
    HomeWidget.updateWidget(name: 'CoupleWidget', androidName: 'CoupleWidget');
  }
}
