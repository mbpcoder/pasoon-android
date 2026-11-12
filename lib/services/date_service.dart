import 'package:pasoonate/pasoonate.dart';

class JalaliDate {
  const JalaliDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}

class DateService {
  const DateService();

  static const List<String> jalaliMonths = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> weekdayShort = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  CalendarManager _at(DateTime date) {
    final noon = DateTime(date.year, date.month, date.day, 12);
    return Pasoonate.make(noon.millisecondsSinceEpoch ~/ 1000);
  }

  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  JalaliDate toJalali(DateTime date) {
    final m = _at(date).jalali();
    return JalaliDate(m.getYear(), m.getMonth(), m.getDay());
  }

  DateTime fromJalali(int year, int month, int day) {
    final m = Pasoonate.make().jalali().setDate(year, month, day).setTime(12, 0, 0);
    final dt = DateTime.fromMillisecondsSinceEpoch(m.getTimestamp() * 1000);
    return DateTime(dt.year, dt.month, dt.day);
  }

  int daysInJalaliMonth(int year, int month) {
    if (month <= 6) {
      return 31;
    }
    if (month <= 11) {
      return 30;
    }
    return Pasoonate.make().jalali().setDate(year, 1, 1).isLeapYear() ? 30 : 29;
  }

  JalaliDate addJalaliMonths(int year, int month, int count) {
    final index = year * 12 + (month - 1) + count;
    return JalaliDate(index ~/ 12, index % 12 + 1, 1);
  }

  int weekdayIndex(DateTime date) => _at(date).jalali().dayOfWeek();

  bool isFriday(DateTime date) => weekdayIndex(date) == 6;

  String weekdayName(DateTime date) => _at(date).jalali().format('dddd');

  String jalaliMonthName(int month) => jalaliMonths[month - 1];

  String jalaliLong(DateTime date) {
    final j = toJalali(date);
    return '${faDigits(j.day)} ${jalaliMonthName(j.month)} ${faDigits(j.year)}';
  }

  String hijriLong(DateTime date) => faDigits(_at(date).shia().format('d MMMM yyyy'));

  String hijriMonthName(DateTime date) => _at(date).shia().format('MMMM');

  String gregorianLong(DateTime date) => _at(date).gregorian().format('d MMMM yyyy');

  String gregorianShortMonth(DateTime date) => _at(date).gregorian().format('MMM yyyy');

  String key(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String faDigits(Object value) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return value.toString().replaceAllMapped(RegExp(r'[0-9]'), (m) => fa[int.parse(m[0]!)]);
  }
}
