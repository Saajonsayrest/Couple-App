import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Guess timezone based on offset since the plugin is failing to build
    try {
      final String guessedZone = _guessTimezone();
      tz.setLocalLocation(tz.getLocation(guessedZone));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!reminder.isNotificationEnabled ||
        reminder.dateTime.isBefore(DateTime.now())) {
      return;
    }

    final id = reminder.id.hashCode;

    await _notificationsPlugin.zonedSchedule(
      id,
      'Friendly Reminder 🔔',
      reminder.title,
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    await _notificationsPlugin.cancel(reminderId.hashCode);
  }

  String _guessTimezone() {
    final DateTime now = DateTime.now();
    final int offsetMinutes = now.timeZoneOffset.inMinutes;
    final int hours = offsetMinutes ~/ 60;
    final int minutes = (offsetMinutes % 60).abs();

    // Check specific common offsets
    if (hours == 5 && minutes == 45) return 'Asia/Kathmandu';
    if (hours == 5 && minutes == 30) return 'Asia/Kolkata';
    if (hours == 0 && minutes == 0) return 'UTC';

    // Generic fallback based on offset sign
    final String sign = offsetMinutes >= 0 ? '+' : '-';
    final String formattedOffset =
        '${sign}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    // The timezone package doesn't support generic offsets like Etv/GMT+5 easily
    // So we try to find a city that matches this offset if possible, otherwise UTC
    return 'UTC';
  }
}
