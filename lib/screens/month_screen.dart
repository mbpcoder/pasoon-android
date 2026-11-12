import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../providers/providers.dart';
import '../services/date_service.dart';
import '../theme.dart';
import 'event_form_screen.dart';

class MonthScreen extends ConsumerStatefulWidget {
  const MonthScreen({super.key});

  @override
  ConsumerState<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends ConsumerState<MonthScreen> {
  static const int _origin = 1200;

  final PageController _pages = PageController(initialPage: _origin);
  late final JalaliDate _base;
  late DateTime _selected;
  int _offset = 0;

  DateService get _ds => ref.read(dateServiceProvider);

  @override
  void initState() {
    super.initState();
    final today = _ds.today();
    final j = _ds.toJalali(today);
    _base = JalaliDate(j.year, j.month, 1);
    _selected = today;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  JalaliDate _monthAt(int offset) => _ds.addJalaliMonths(_base.year, _base.month, offset);

  void _onPage(int page) {
    final offset = page - _origin;
    final m = _monthAt(offset);
    setState(() {
      _offset = offset;
      _selected = offset == 0 ? _ds.today() : _ds.fromJalali(m.year, m.month, 1);
    });
  }

  void _go(int delta) {
    _pages.animateToPage(_origin + _offset + delta, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final ds = ref.watch(dateServiceProvider);
    final events = ref.watch(eventsByDateProvider);
    final current = _monthAt(_offset);
    final prev = _monthAt(_offset - 1);
    final next = _monthAt(_offset + 1);
    final first = ds.fromJalali(current.year, current.month, 1);
    final last = ds.fromJalali(current.year, current.month, ds.daysInJalaliMonth(current.year, current.month));

    return Scaffold(
      appBar: AppBar(title: const Text('تقویم', style: TextStyle(fontWeight: FontWeight.w700))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'رویداد جدید',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventFormScreen(date: _selected))),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: TextButton.icon(
                    onPressed: () => _go(-1),
                    icon: const Icon(Icons.chevron_right),
                    label: Text(ds.jalaliMonthName(prev.month)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.muted, minimumSize: const Size(44, 44)),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('${ds.jalaliMonthName(current.month)} ${DateService.faDigits(current.year)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(
                        '${ds.gregorianShortMonth(first)} – ${ds.gregorianShortMonth(last)}',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      Text('${ds.hijriMonthName(first)} – ${ds.hijriMonthName(last)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextButton.icon(
                      onPressed: () => _go(1),
                      icon: const Icon(Icons.chevron_left),
                      label: Text(ds.jalaliMonthName(next.month)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.muted, minimumSize: const Size(44, 44)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(DateService.weekdayShort[i],
                          style: TextStyle(fontSize: 12, color: i == 6 ? AppColors.holiday : AppColors.muted)),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 6 * 56,
            child: PageView.builder(
              controller: _pages,
              onPageChanged: _onPage,
              itemBuilder: (_, page) => _MonthGrid(
                month: _monthAt(page - _origin),
                selected: _selected,
                events: events,
                onSelect: (d) => setState(() => _selected = d),
              ),
            ),
          ),
          Expanded(child: _DayPanel(date: _selected, events: events[ds.key(_selected)] ?? const [])),
        ],
      ),
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({required this.month, required this.selected, required this.events, required this.onSelect});

  final JalaliDate month;
  final DateTime selected;
  final Map<String, List<CalendarEvent>> events;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dateServiceProvider);
    final first = ds.fromJalali(month.year, month.month, 1);
    final lead = ds.weekdayIndex(first);
    final days = ds.daysInJalaliMonth(month.year, month.month);
    final todayKey = ds.key(ds.today());
    final selectedKey = ds.key(selected);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 52,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: lead + days,
      itemBuilder: (_, i) {
        if (i < lead) {
          return const SizedBox.shrink();
        }
        final day = i - lead + 1;
        final date = DateTime(first.year, first.month, first.day + day - 1);
        final key = ds.key(date);
        final isSelected = key == selectedKey;
        final isToday = key == todayKey;
        final isFriday = (i % 7) == 6;
        final hasEvents = events[key]?.isNotEmpty ?? false;

        return Material(
          color: isSelected ? AppColors.primary : (isToday ? AppColors.primaryLight : Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isToday && !isSelected ? AppColors.primary : AppColors.border,
              width: isToday && !isSelected ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(date),
            child: Semantics(
              label: '${ds.weekdayName(date)} ${ds.jalaliLong(date)}',
              button: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateService.faDigits(day),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : (isFriday ? AppColors.holiday : AppColors.text),
                    ),
                  ),
                  Text('${date.day}',
                      style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primaryLight : const Color(0xFF6B7280))),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasEvents ? (isSelected ? Colors.white : AppColors.eventDot) : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DayPanel extends ConsumerWidget {
  const _DayPanel({required this.date, required this.events});

  final DateTime date;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dateServiceProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ds.weekdayName(date), style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                    Text(ds.jalaliLong(date), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ds.gregorianLong(date),
                      textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  Text(ds.hijriLong(date), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('رویدادی در این روز نیست', style: TextStyle(color: AppColors.muted)))
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final e = events[i];
                      return Material(
                        color: AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: Container(width: 4, height: 32, color: AppColors.primary),
                          title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(e.time == null ? 'تمام روز' : DateService.faDigits(e.time!)),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => EventFormScreen(date: date, event: e))),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
