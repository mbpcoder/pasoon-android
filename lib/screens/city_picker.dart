import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cities.dart';
import '../providers/providers.dart';
import '../theme.dart';

Future<void> showCityPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => const _CityPicker(),
  );
}

class _CityPicker extends ConsumerStatefulWidget {
  const _CityPicker();

  @override
  ConsumerState<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends ConsumerState<_CityPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(cityProvider);
    final list = cities.where((c) => _query.isEmpty || c.name.contains(_query)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('انتخاب شهر', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'جستجو',
                  hintText: 'نام شهر',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final city = list[i];
                  final isSelected = city.id == selected.id;
                  return ListTile(
                    title: Text(city.name),
                    trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () async {
                      await ref.read(cityProvider.notifier).select(city);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
