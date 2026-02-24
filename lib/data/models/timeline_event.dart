import 'package:hive/hive.dart';

class TimelineEvent {
  final String id;
  final DateTime date;
  final String title;
  final String body;
  final bool isSystemEvent;
  final int? serverId;

  TimelineEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    this.isSystemEvent = false,
    this.serverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'body': body,
      'isSystemEvent': isSystemEvent,
      'serverId': serverId,
    };
  }

  factory TimelineEvent.fromMap(Map<dynamic, dynamic> map) {
    return TimelineEvent(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      body: map['body'] as String,
      isSystemEvent: map['isSystemEvent'] as bool? ?? false,
      serverId: map['serverId'] as int?,
    );
  }
}

class TimelineEventAdapter extends TypeAdapter<TimelineEvent> {
  @override
  final int typeId = 1; // Assuming 1 for TimelineEvent

  @override
  TimelineEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimelineEvent(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      title: fields[2] as String,
      body: fields[3] as String,
      isSystemEvent: fields[4] as bool,
      serverId: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TimelineEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.isSystemEvent)
      ..writeByte(5)
      ..write(obj.serverId);
  }
}
