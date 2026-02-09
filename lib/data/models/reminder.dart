class Reminder {
  final String id;
  String title;
  DateTime dateTime;
  bool isCompleted;
  bool isNotificationEnabled;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
    this.isNotificationEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  factory Reminder.fromMap(Map<dynamic, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      dateTime: DateTime.parse(map['dateTime']),
      isCompleted: map['isCompleted'] ?? false,
      isNotificationEnabled: map['isNotificationEnabled'] ?? true,
    );
  }
}
