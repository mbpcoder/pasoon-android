import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/city.dart';
import 'date_service.dart';
import 'owghat_service.dart';

/// Sends the next days' dates and owghat to the native Android side, which
/// shows them in an ongoing notification and refreshes it at midnight and
/// after each prayer time, even while the app is closed.
class TodayNotificationService {
  const TodayNotificationService({this.dates = const DateService(), this.owghat = const OwghatService()});

  static const MethodChannel _channel = MethodChannel('ir.pasoon/today_notification');
  static const int days = 30;
  static const List<String> _labels = ['صبح', 'طلوع', 'ظهر', 'مغرب', 'عشا'];

  final DateService dates;
  final OwghatService owghat;

  List<Map<String, Object>> build(City city, DateTime start) {
    final entries = <Map<String, Object>>[];
    for (var i = 0; i < days; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final times = owghat.forDate(city, date).take(_labels.length).toList();
      entries.add({
        'date': dates.key(date),
        'day': dates.toJalali(date).day,
        'title': '${dates.weekdayName(date)} ${dates.jalaliLong(date)}',
        'subtitle': '${dates.gregorianLong(date)} · ${dates.hijriLong(date)}',
        'city': city.name,
        'times': [
          for (var t = 0; t < times.length; t++)
            {
              'label': _labels[t],
              'text': DateService.faDigits(
                  '${times[t].time.hour.toString().padLeft(2, '0')}:${times[t].time.minute.toString().padLeft(2, '0')}'),
              // Owghat times are UTC shifted by the Iran offset; convert back to a real instant.
              'at': times[t].time.millisecondsSinceEpoch - OwghatService.iranOffset.inMilliseconds,
            },
        ],
      });
    }
    return entries;
  }

  Future<void> sync(City city) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('sync', jsonEncode(build(city, dates.today())));
    } on PlatformException catch (e) {
      debugPrint('Today notification sync failed: $e');
    } on MissingPluginException {
      // Not available (e.g. in tests).
    }
  }
}
