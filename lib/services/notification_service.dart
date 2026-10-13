import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../data/models/reminder.dart';
import '../data/models/user_profile.dart';

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

    await _cancelDailyQuotes();
  }

  // Daily 6 AM love quotes were turned off as too frequent. Older builds
  // queued them a week ahead (ids 9000-9006), so clear any still pending.
  Future<void> _cancelDailyQuotes() async {
    for (int id = 9000; id <= 9006; id++) {
      await _notificationsPlugin.cancel(id);
    }
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel('daily_quotes_channel');
  }

  /// Alerts that must never be missed: anniversary, both birthdays, New Year
  /// and the first of every month. Fixed ids, so calling this again just
  /// reschedules.
  Future<void> scheduleImportantDates(
    UserProfile me,
    UserProfile partner,
  ) async {
    // Anniversary
    if (me.relationshipStartDate != null) {
      await scheduleAnnualEvent(
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
    await scheduleAnnualEvent(
      id: 1002,
      title: 'Happy Birthday $partnerName! 🎂',
      body: "Today is $partnerName's special day! Make it amazing! 🎉",
      date: partner.birthday,
    );

    // My Birthday
    await scheduleAnnualEvent(
      id: 1003,
      title: 'Happy Birthday to You! 🎂',
      body: "It's your special day! Hope $partnerName spoils you! 🎁",
      date: me.birthday,
    );

    // New Year
    await scheduleAnnualEvent(
      id: 1004,
      title: 'Happy New Year! 🎆',
      body:
          'Another year together with $partnerName. Here’s to the best one yet! 🥂',
      date: DateTime(2000, 1, 1),
    );

    // First of every month. January is covered by New Year above, so these
    // are 11 yearly alerts (ids 1102-1112) rather than one monthly repeat
    // that would double up on 1 January.
    const months = [
      'February', 'March', 'April', 'May', 'June', 'July', //
      'August', 'September', 'October', 'November', 'December',
    ];
    for (int month = 2; month <= 12; month++) {
      await scheduleAnnualEvent(
        id: 1100 + month,
        title: 'Hello, ${months[month - 2]}! 🌸',
        body:
            'A fresh month with $partnerName. Plan something sweet together! 💕',
        date: DateTime(2000, month, 1),
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
