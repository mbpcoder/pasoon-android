import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/event.dart';

class EventRepository {
  EventRepository(this._db);

  final Database _db;

  static Future<EventRepository> open() async {
    final path = p.join(await getDatabasesPath(), 'pasoon.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT,
            note TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT
          )
        ''');
        await db.execute('CREATE INDEX events_date ON events (date)');
      },
    );
    return EventRepository(db);
  }

  Future<List<CalendarEvent>> all() async {
    final rows = await _db.query('events', where: 'deleted_at IS NULL', orderBy: 'date, time');
    return rows.map(CalendarEvent.fromMap).toList();
  }

  Future<void> save(CalendarEvent event) async {
    await _db.insert('events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
