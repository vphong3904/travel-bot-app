// lib/admin/web/widgets/city_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/content_provider.dart';

/// Dropdown chọn thành phố cho filter content.
/// Lấy danh sách từ /admin/cities (tên đẹp), value = slug. '' = Tất cả.
class CitySelector extends ConsumerWidget {
  final String value;
  final ValueChanged<String> onChange;

  const CitySelector({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(citiesProvider);

    return citiesAsync.when(
      loading: () => const SizedBox(
        width: 200,
        height: 40,
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const Text('Lỗi load danh sách thành phố'),
      data: (cities) => DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.location_city, size: 18),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: [
          const DropdownMenuItem(
            value: '',
            child: Text('Tất cả thành phố',
                style: TextStyle(fontSize: 13)),
          ),
          ...cities.map((c) => DropdownMenuItem(
                value: c.slug,
                child: Text(
                  c.name,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
        onChanged: (v) => onChange(v ?? ''),
      ),
    );
  }
}
