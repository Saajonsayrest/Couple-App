import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../data/models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';

class ReminderState {
  final List<Reminder> reminders;
  final bool isLoading;
  final String? error;

  ReminderState({
    this.reminders = const [],
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
    String? error,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderService _reminderService;
  final NotificationService _notificationService = NotificationService();

  ReminderNotifier(this._reminderService) : super(ReminderState()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    // 1. Load from Hive
    final box = Hive.box<Reminder>(AppConstants.remindersBox);
    state = state.copyWith(reminders: box.values.toList(), isLoading: true);

    // 2. Sync from API
    try {
      final apiReminders = await _reminderService.getReminders();
      final List<Reminder> syncedReminders = [];

      for (var data in apiReminders) {
        syncedReminders.add(
          Reminder(
            id: data['id'].toString(),
            title: data['title'],
            dateTime: DateTime.parse(data['date_time']),
            isCompleted: data['is_completed'] ?? false,
            isNotificationEnabled: data['is_notification_enabled'] ?? true,
            serverId: data['id'],
          ),
        );
      }

      // Update Hive cache
      await box.clear();
      for (var reminder in syncedReminders) {
        await box.add(reminder);
        // Reschedule notifications from synced data if enabled
        if (reminder.isNotificationEnabled && !reminder.isCompleted) {
          await _notificationService.scheduleReminder(reminder);
        }
      }

      state = state.copyWith(reminders: syncedReminders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _reminderService.createReminder(reminder);
      final newReminder = Reminder(
        id: response['id'].toString(),
        title: reminder.title,
        dateTime: reminder.dateTime,
        isCompleted: reminder.isCompleted,
        isNotificationEnabled: reminder.isNotificationEnabled,
        serverId: response['id'],
      );

      final box = Hive.box<Reminder>(AppConstants.remindersBox);
      await box.add(newReminder);

      if (newReminder.isNotificationEnabled) {
        await _notificationService.scheduleReminder(newReminder);
      }

      state = state.copyWith(
        reminders: [...state.reminders, newReminder],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (reminder.serverId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _reminderService.updateReminder(reminder.serverId!, reminder);

      final box = Hive.box<Reminder>(AppConstants.remindersBox);
      final key = box.keys.firstWhere(
        (k) => box.get(k)?.serverId == reminder.serverId,
      );
      await box.put(key, reminder);

      if (reminder.isNotificationEnabled && !reminder.isCompleted) {
        await _notificationService.scheduleReminder(reminder);
      } else {
        await _notificationService.cancelReminder(reminder.id);
      }

      state = state.copyWith(
        reminders: state.reminders
            .map((r) => r.serverId == reminder.serverId ? reminder : r)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteReminder(String id, int? serverId) async {
    state = state.copyWith(isLoading: true);
    try {
      if (serverId != null) {
        await _reminderService.deleteReminder(serverId);
      }

      final box = Hive.box<Reminder>(AppConstants.remindersBox);
      final key = box.keys.firstWhere(
        (k) =>
            box.get(k)?.id == id ||
            (serverId != null && box.get(k)?.serverId == serverId),
      );
      await box.delete(key);
      await _notificationService.cancelReminder(id);

      state = state.copyWith(
        reminders: state.reminders
            .where((r) => r.id != id && r.serverId != serverId)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>(
  (ref) {
    final reminderService = ref.watch(reminderServiceProvider);
    return ReminderNotifier(reminderService);
  },
);
