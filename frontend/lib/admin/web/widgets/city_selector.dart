// lib/admin/web/widgets/city_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/content_provider.dart';

class CitySelector extends ConsumerWidget {
  final String value;
  final ValueChanged<String> onChange;

  const CitySelector(
      {super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slugsAsync = ref.watch(validCitySlugsProvider);

    return slugsAsync.when(
      loading: () => const SizedBox(
        width: 200,
        height: 40,
        child: LinearProgressIndicator(),
      ),
      error: (_, __) =>
          const Text('Lỗi load danh sách thành phố'),
      data: (slugs) => DropdownButtonFormField<String>(
        initialValue: value.isEmpty ? null : value,
        hint: const Text('Chọn thành phố...'),
        decoration: InputDecoration(
          prefixIcon:
              const Icon(Icons.location_city, size: 18),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
        ),
        items: slugs
            .map((slug) => DropdownMenuItem(
                  value: slug,
                  child: Text(
                    slug,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChange(v);
        },
      ),

    );
  }
}
