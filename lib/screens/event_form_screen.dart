import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../providers/providers.dart';
import '../services/date_service.dart';
import '../theme.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, required this.date, this.event});

  final DateTime date;
  final CalendarEvent? event;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(text: widget.event?.title);
  late final TextEditingController _note = TextEditingController(text: widget.event?.note);
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final t = widget.event?.time;
    if (t != null) {
      final parts = t.split(':');
      _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  String? get _timeString =>
      _time == null ? null : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final notifier = ref.read(eventsProvider.notifier);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final event = widget.event;
    if (event == null) {
      await notifier.add(
        title: _title.text.trim(),
        date: ref.read(dateServiceProvider).key(widget.date),
        time: _timeString,
        note: note,
      );
    } else {
      await notifier.edit(event, title: _title.text.trim(), time: _timeString, note: note);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final event = widget.event;
    if (event == null) {
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('حذف رویداد'),
        content: Text('«${event.title}» حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('انصراف')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    await ref.read(eventsProvider.notifier).remove(event);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = ref.watch(dateServiceProvider);
    final isEdit = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'ویرایش رویداد' : 'رویداد جدید'),
        actions: [
          if (isEdit) IconButton(tooltip: 'حذف', onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${ds.weekdayName(widget.date)} ${ds.jalaliLong(widget.date)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              autofocus: !isEdit,
              decoration: const InputDecoration(labelText: 'عنوان', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'عنوان را وارد کنید' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(44, 52)),
                    icon: const Icon(Icons.schedule),
                    label: Text(_timeString == null ? 'تمام روز' : DateService.faDigits(_timeString!)),
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
                      if (picked != null) {
                        setState(() => _time = picked);
                      }
                    },
                  ),
                ),
                if (_time != null)
                  IconButton(tooltip: 'تمام روز', onPressed: () => setState(() => _time = null), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'یادداشت', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52)),
              onPressed: _save,
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}
