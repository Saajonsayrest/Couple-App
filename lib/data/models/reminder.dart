import 'package:hive/hive.dart';

class Reminder {
  final String id;
  String title;
  DateTime dateTime;
  bool isCompleted;
  bool isNotificationEnabled;
  int? serverId;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
    this.isNotificationEnabled = true,
    this.serverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'isNotificationEnabled': isNotificationEnabled,
      'serverId': serverId,
    };
  }

  factory Reminder.fromMap(Map<dynamic, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      dateTime: DateTime.parse(map['dateTime']),
      isCompleted: map['isCompleted'] ?? false,
      isNotificationEnabled: map['isNotificationEnabled'] ?? true,
      serverId: map['serverId'] as int?,
    );
  }
}

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 2; // Assuming 2 for Reminder

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      dateTime: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
      isNotificationEnabled: fields[4] as bool,
      serverId: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.isNotificationEnabled)
      ..writeByte(5)
      ..write(obj.serverId);
  }
}
