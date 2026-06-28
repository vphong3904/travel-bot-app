// lib/admin/web/screens/city_mapping_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/city_mapping_models.dart';
import '../../shared/providers/city_mapping_provider.dart';
import '../../shared/data/city_mapping_repository.dart';

class CityMappingScreen extends ConsumerWidget {
  const CityMappingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappingsAsync = ref.watch(cityMappingsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City Slug Mapping',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quản lý alias tỉnh/thành phố → folder knowledge-base',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              mappingsAsync.when(
                data: (mappings) {
                  final broken = mappings
                      .where((m) => !m.folderExists)
                      .length;
                  if (broken == 0) return const SizedBox();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      '$broken/${mappings.length} mapping có vấn đề',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: mappingsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Lỗi: $e')),
              data: (mappings) => SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                      Colors.grey.shade50),
                  columns: const [
                    DataColumn(label: Text('Tỉnh cũ')),
                    DataColumn(label: Text('Slug hiện tại')),
                    DataColumn(
                        label: Text('Folder tồn tại?')),
                    DataColumn(label: Text('Gợi ý')),
                    DataColumn(label: Text('')),
                  ],
                  rows: mappings
                      .map((m) => DataRow(
                            color: WidgetStateProperty.resolveWith(
                              (states) => m.folderExists
                                  ? null
                                  : Colors.red.shade50,
                            ),
                            cells: [
                              DataCell(Text(m.oldProvince,
                                  style: const TextStyle(
                                      fontSize: 13))),
                              DataCell(Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m.mappedSlug,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              )),
                              DataCell(Row(
                                children: [
                                  Icon(
                                    m.folderExists
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 16,
                                    color: m.folderExists
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    m.folderExists
                                        ? 'OK'
                                        : 'Không tìm thấy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: m.folderExists
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              )),
                              DataCell(m.suggestion != null
                                  ? Row(
                                      children: [
                                        const Icon(
                                            Icons.lightbulb_outline,
                                            size: 14,
                                            color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          m.suggestion!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber),
                                        ),
                                      ],
                                    )
                                  : const Text('—',
                                      style: TextStyle(
                                          color: Colors.grey))),
                              DataCell(m.folderExists
                                  ? const SizedBox()
                                  : TextButton(
                                      onPressed: () => _showFixDialog(
                                          context, ref, m),
                                      child: const Text('Sửa'),
                                    )),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFixDialog(
    BuildContext context,
    WidgetRef ref,
    CityMapping mapping,
  ) async {
    final validSlugs =
        await ref.read(validSlugsProvider.future);

    String? selectedSlug = mapping.suggestion;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title:
              Text('Sửa mapping: ${mapping.oldProvince}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn slug folder hợp lệ:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedSlug,
                hint: const Text('Chọn slug...'),
                isExpanded: true,
                items: validSlugs
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
                onChanged: (v) =>
                    setDialogState(() => selectedSlug = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: selectedSlug == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || selectedSlug == null) return;

    await ref
        .read(cityMappingRepositoryProvider)
        .updateMapping(mapping.oldProvince, selectedSlug!);
    ref.invalidate(cityMappingsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đã cập nhật mapping cho ${mapping.oldProvince}'),
        ),
      );
    }
  }
}
