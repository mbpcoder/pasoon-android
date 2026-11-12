import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../services/date_service.dart';
import '../theme.dart';
import 'city_picker.dart';
import 'month_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پسون', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: const [
          _TodayCard(),
          SizedBox(height: 16),
          _OwghatCard(),
        ],
      ),
    );
  }
}

class _TodayCard extends ConsumerWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dateServiceProvider);
    final today = ds.today();
    final j = ds.toJalali(today);
    final events = ref.watch(eventsByDateProvider)[ds.key(today)] ?? const [];

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MonthScreen())),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ds.weekdayName(today), style: const TextStyle(fontSize: 16)),
                          Text(DateService.faDigits(j.day), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, height: 1.1)),
                          Text('${ds.jalaliMonthName(j.month)} ${DateService.faDigits(j.year)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Pill(text: ds.gregorianLong(today), ltr: true),
                        const SizedBox(height: 6),
                        _Pill(text: ds.hijriLong(today)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFF14B8A6)),
                const SizedBox(height: 12),
                if (events.isEmpty)
                  const Text('رویدادی برای امروز ثبت نشده', style: TextStyle(color: AppColors.primaryLight)),
                for (final e in events)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      if (e.time != null) ...[
                        Text(DateService.faDigits(e.time!), style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                      ],
                      Expanded(child: Text(e.title, overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                const SizedBox(height: 8),
                const Text('برای دیدن تقویم ماه لمس کنید', style: TextStyle(fontSize: 12, color: AppColors.primaryLight)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.ltr = false});

  final String text;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(8)),
      child: Text(text, textDirection: ltr ? TextDirection.ltr : null, style: const TextStyle(fontSize: 13, color: Colors.white)),
    );
  }
}

class _OwghatCard extends ConsumerWidget {
  const _OwghatCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(cityProvider);
    final service = ref.watch(owghatServiceProvider);
    final now = service.nowInIran();
    final times = service.forDate(city, DateTime(now.year, now.month, now.day));
    final next = service.nextIndex(times, now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('اوقات شرعی', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
              OutlinedButton.icon(
                onPressed: () => showCityPicker(context),
                icon: const Icon(Icons.place_outlined, size: 18),
                label: Text(city.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(minimumSize: const Size(44, 44)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.4,
            children: [
              for (var i = 0; i < times.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: i == next ? AppColors.primaryLight : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(times[i].label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
                      Text(_hm(times[i].time), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('روش محاسبه: مؤسسه ژئوفیزیک تهران', style: TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }

  String _hm(DateTime t) =>
      DateService.faDigits('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
}
