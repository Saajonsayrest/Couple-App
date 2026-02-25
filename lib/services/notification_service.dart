import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../data/models/reminder.dart';
import '../data/game_data.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      String timeZoneName;
      if (tzInfo is String) {
        timeZoneName = tzInfo;
      } else {
        // Fallback for TimezoneInfo object (version 5.0.1+)
        try {
          timeZoneName = tzInfo.name ?? 'UTC';
        } catch (_) {
          try {
            timeZoneName = (tzInfo as dynamic).identifier ?? 'UTC';
          } catch (_) {
            timeZoneName = 'UTC';
          }
        }
      }
      tz.setLocalLocation(tz.getLocation(timeZoneName));
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

    // Create Love Quotes channel for Android
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'daily_quotes_channel',
        'Daily Love Quotes',
        description: 'Morning love quotes for your partner',
        importance: Importance.low, // Silent by default
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );

    // Automatically schedule quotes on init
    await scheduleDailyQuoteNotification();
  }

  Future<void> scheduleDailyQuoteNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final random = Random();
    final quotes = GameData.coupleQuotes;

    for (int i = 0; i < 7; i++) {
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        6, // 6 AM
        0,
        0,
      ).add(Duration(days: i));

      // If scheduled time has already passed today, don't schedule for today
      if (scheduledDate.isBefore(now)) {
        continue;
      }

      // Use a consistent ID range for daily quotes (e.g., 9000-9006)
      final id = 9000 + i;

      // Select a truly random quote
      final quote = quotes[random.nextInt(quotes.length)];

      await _notificationsPlugin.zonedSchedule(
        id,
        'Good Morning! ❤️',
        quote,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_quotes_channel',
            'Daily Love Quotes',
            channelDescription: 'Morning love quotes for your partner',
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            enableVibration: false,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false, // Silent
            interruptionLevel: InterruptionLevel.passive, // Less intrusive
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
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

    // Use a positive 31-bit integer for the notification id
    final id = reminder.id.hashCode & 0x7FFFFFFF;

    await _notificationsPlugin.zonedSchedule(
      id,
      'Sweet Reminder ❤️',
      reminder.title,
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Channel for scheduled reminders',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,
          styleInformation: BigTextStyleInformation(''),
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleAnnualEvent({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Construct the next occurrence at 12:00 AM (00:00)
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      date.month,
      date.day,
      0,
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        date.month,
        date.day,
        0,
        0,
        0,
      );
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'special_events_channel',
            'Special Events',
            channelDescription: 'Birthdays and Anniversaries',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      print("Error scheduling annual event: $e");
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    await _notificationsPlugin.cancel(reminderId.hashCode & 0x7FFFFFFF);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
