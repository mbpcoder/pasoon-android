import 'package:flutter_test/flutter_test.dart';
import 'package:pasoon/data/cities.dart';
import 'package:pasoon/services/today_notification_service.dart';

void main() {
  const service = TodayNotificationService();
  final tehran = cities.firstWhere((c) => c.id == defaultCityId);

  test('builds 30 days of dates and five owghat times', () {
    final entries = service.build(tehran, DateTime(2026, 11, 12));
    expect(entries.length, TodayNotificationService.days);
    final first = entries.first;
    expect(first['date'], '2026-11-12');
    expect(first['day'], 21);
    expect(first['title'], contains('آبان'));
    final times = first['times'] as List;
    expect(times.map((t) => t['label']), ['صبح', 'طلوع', 'ظهر', 'مغرب', 'عشا']);
  });

  test('owghat instants fall on the right day in Iran time', () {
    final times = service.build(tehran, DateTime(2026, 11, 12)).first['times'] as List;
    final dhuhr = DateTime.fromMillisecondsSinceEpoch(times[2]['at'] as int, isUtc: true)
        .add(const Duration(hours: 3, minutes: 30));
    expect([dhuhr.year, dhuhr.month, dhuhr.day, dhuhr.hour], [2026, 11, 12, 11]);
    expect(times[2]['text'], startsWith('۱۱:'));
  });
}
