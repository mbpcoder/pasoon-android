import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/cities.dart';
import '../models/city.dart';
import '../models/event.dart';
import '../services/date_service.dart';
import '../services/event_repository.dart';
import '../services/owghat_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final eventRepositoryProvider = Provider<EventRepository>((ref) => throw UnimplementedError());

final dateServiceProvider = Provider<DateService>((ref) => const DateService());

final owghatServiceProvider = Provider<OwghatService>((ref) => const OwghatService());

class CityNotifier extends Notifier<City> {
  static const String _key = 'city_id';

  @override
  City build() {
    final id = ref.read(sharedPreferencesProvider).getString(_key) ?? defaultCityId;
    return cities.firstWhere((c) => c.id == id, orElse: () => cities.first);
  }

  Future<void> select(City city) async {
    state = city;
    await ref.read(sharedPreferencesProvider).setString(_key, city.id);
  }
}

final cityProvider = NotifierProvider<CityNotifier, City>(CityNotifier.new);

class EventsNotifier extends AsyncNotifier<List<CalendarEvent>> {
  EventRepository get _repo => ref.read(eventRepositoryProvider);

  @override
  Future<List<CalendarEvent>> build() => _repo.all();

  Future<void> add({required String title, required String date, String? time, String? note}) async {
    final now = DateTime.now();
    await _repo.save(CalendarEvent(
      id: const Uuid().v4(),
      title: title,
      date: date,
      time: time,
      note: note,
      createdAt: now,
      updatedAt: now,
    ));
    state = AsyncData(await _repo.all());
  }

  Future<void> edit(CalendarEvent event, {required String title, String? time, String? note}) async {
    await _repo.save(event.copyWith(title: title, time: time, note: note, updatedAt: DateTime.now()));
    state = AsyncData(await _repo.all());
  }

  Future<void> remove(CalendarEvent event) async {
    final now = DateTime.now();
    await _repo.save(event.copyWith(time: event.time, note: event.note, updatedAt: now, deletedAt: now));
    state = AsyncData(await _repo.all());
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<CalendarEvent>>(EventsNotifier.new);

final eventsByDateProvider = Provider<Map<String, List<CalendarEvent>>>((ref) {
  final events = ref.watch(eventsProvider).value ?? const <CalendarEvent>[];
  final map = <String, List<CalendarEvent>>{};
  for (final e in events) {
    map.putIfAbsent(e.date, () => []).add(e);
  }
  return map;
});
