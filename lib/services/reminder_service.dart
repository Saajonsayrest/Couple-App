import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../core/api_constants.dart';
import '../data/models/reminder.dart';

final reminderServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReminderService(apiService);
});

class ReminderService {
  final ApiService _apiService;

  ReminderService(this._apiService);

  Future<List<Map<String, dynamic>>> getReminders() async {
    final response = await _apiService.get(ApiConstants.reminders);
    final data = response.data;
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['reminders']);
    } else {
      throw Exception(data['error'] ?? 'Failed to get reminders');
    }
  }

  Future<Map<String, dynamic>> createReminder(Reminder reminder) async {
    final response = await _apiService.post(ApiConstants.reminders, {
      'title': reminder.title,
      'date_time': reminder.dateTime.toIso8601String(),
      'is_completed': reminder.isCompleted,
      'is_notification_enabled': reminder.isNotificationEnabled,
    });

    final data = response.data;
    if (response.statusCode == 201) {
      return data['reminder'];
    } else {
      throw Exception(data['error'] ?? 'Failed to create reminder');
    }
  }

  Future<Map<String, dynamic>> updateReminder(int id, Reminder reminder) async {
    final response = await _apiService.put('${ApiConstants.reminders}/$id', {
      'title': reminder.title,
      'date_time': reminder.dateTime.toIso8601String(),
      'is_completed': reminder.isCompleted,
      'is_notification_enabled': reminder.isNotificationEnabled,
    });

    final data = response.data;
    if (response.statusCode == 200) {
      return data['reminder'];
    } else {
      throw Exception(data['error'] ?? 'Failed to update reminder');
    }
  }

  Future<void> deleteReminder(int id) async {
    final response = await _apiService.delete('${ApiConstants.reminders}/$id');
    if (response.statusCode != 200) {
      final data = response.data;
      throw Exception(data['error'] ?? 'Failed to delete reminder');
    }
  }
}
