class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String date;
  final String? time;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CalendarEvent copyWith({String? title, String? date, String? time, String? note, DateTime? updatedAt, DateTime? deletedAt}) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'date': date,
        'time': time,
        'note': note,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  factory CalendarEvent.fromMap(Map<String, Object?> map) => CalendarEvent(
        id: map['id'] as String,
        title: map['title'] as String,
        date: map['date'] as String,
        time: map['time'] as String?,
        note: map['note'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
        deletedAt: map['deleted_at'] == null ? null : DateTime.parse(map['deleted_at'] as String),
      );
}
