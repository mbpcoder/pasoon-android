import 'package:adhan/adhan.dart';

import '../models/city.dart';

class OwghatTime {
  const OwghatTime(this.label, this.time);

  final String label;
  final DateTime time;
}

class OwghatService {
  const OwghatService();

  static const Duration iranOffset = Duration(hours: 3, minutes: 30);

  List<OwghatTime> forDate(City city, DateTime date) {
    final params = CalculationMethod.tehran.getParameters();
    final times = PrayerTimes.utcOffset(
      Coordinates(city.latitude, city.longitude),
      DateComponents(date.year, date.month, date.day),
      params,
      iranOffset,
    );
    final sunnah = SunnahTimes(times);
    return [
      OwghatTime('اذان صبح', times.fajr),
      OwghatTime('طلوع آفتاب', times.sunrise),
      OwghatTime('اذان ظهر', times.dhuhr),
      OwghatTime('اذان مغرب', times.maghrib),
      OwghatTime('عشا', times.isha),
      OwghatTime('نیمه‌شب شرعی', sunnah.middleOfTheNight),
    ];
  }

  int nextIndex(List<OwghatTime> times, DateTime nowIran) {
    final index = times.indexWhere((t) => t.time.isAfter(nowIran));
    return index;
  }

  DateTime nowInIran() => DateTime.now().toUtc().add(iranOffset);
}
