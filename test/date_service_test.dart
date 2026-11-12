import 'package:flutter_test/flutter_test.dart';
import 'package:pasoon/services/date_service.dart';

void main() {
  const ds = DateService();

  test('converts gregorian to jalali', () {
    final j = ds.toJalali(DateTime(2019, 4, 19));
    expect([j.year, j.month, j.day], [1398, 1, 30]);
  });

  test('converts jalali to gregorian', () {
    expect(ds.fromJalali(1403, 1, 1), DateTime(2024, 3, 20));
  });

  test('jalali month lengths', () {
    expect(ds.daysInJalaliMonth(1403, 1), 31);
    expect(ds.daysInJalaliMonth(1403, 7), 30);
    expect(ds.daysInJalaliMonth(1403, 12), 30);
    expect(ds.daysInJalaliMonth(1404, 12), 29);
  });

  test('adds jalali months across years', () {
    final m = ds.addJalaliMonths(1403, 12, 1);
    expect([m.year, m.month], [1404, 1]);
    final p = ds.addJalaliMonths(1403, 1, -1);
    expect([p.year, p.month], [1402, 12]);
  });

  test('weekday index starts on saturday', () {
    expect(ds.weekdayIndex(DateTime(2024, 3, 23)), 0);
    expect(ds.isFriday(DateTime(2024, 3, 22)), isTrue);
  });

  test('persian digits', () {
    expect(DateService.faDigits('12:05'), '۱۲:۰۵');
  });
}
