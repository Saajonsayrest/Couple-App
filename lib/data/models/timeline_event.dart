class TimelineEvent {
  final String id;
  final DateTime date;
  final String title;
  final String body;
  final bool isSystemEvent;

  TimelineEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    this.isSystemEvent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'body': body,
      'isSystemEvent': isSystemEvent,
    };
  }

  factory TimelineEvent.fromMap(Map<dynamic, dynamic> map) {
    return TimelineEvent(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      body: map['body'] as String,
      isSystemEvent: map['isSystemEvent'] as bool? ?? false,
    );
  }
}
