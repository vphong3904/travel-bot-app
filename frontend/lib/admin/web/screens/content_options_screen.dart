// lib/admin/web/screens/content_options_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/content_option_repository.dart';
import '../../shared/models/content_option.dart';

/// Màn quản lý taxonomy: các "loại" theo content_type + field.
/// Admin thêm/sửa/xóa loại; form content đọc động từ đây.
class ContentOptionsScreen extends ConsumerWidget {
  const ContentOptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allContentOptionsProvider);

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
                  Text('Quản lý loại',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Danh sách "loại" cho dropdown form theo từng mục nội dung',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm loại'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
              data: (options) {
                // group by "content_type · field"
                final groups = <String, List<ContentOption>>{};
                for (final o in options) {
                  groups.putIfAbsent('${o.contentType}·${o.field}', () => []).add(o);
                }
                final keys = groups.keys.toList()..sort();
                if (keys.isEmpty) {
                  return const Center(
                      child: Text('Chưa có loại nào — bấm "Thêm loại"',
                          style: TextStyle(color: Colors.grey)));
                }
                return ListView(
                  children: keys.map((k) {
                    final parts = k.split('·');
                    final list = groups[k]!
                      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('${parts[0]}  ·  ${parts[1]}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => _openDialog(context, ref,
                                      contentType: parts[0], field: parts[1]),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Thêm'),
                                ),
                              ],
                            ),
                            const Divider(),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: list
                                  .map((o) => _OptionChip(
                                        option: o,
                                        onEdit: () =>
                                            _openDialog(context, ref, edit: o),
                                        onDelete: () =>
                                            _delete(context, ref, o),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, ContentOption o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá loại?'),
        content: Text('Xoá "${o.label}" (${o.code})?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(contentOptionRepositoryProvider).delete(o.id);
    ref.invalidate(allContentOptionsProvider);
    ref.invalidate(contentOptionsProvider);
  }

  Future<void> _openDialog(
    BuildContext context,
    WidgetRef ref, {
    String? contentType,
    String? field,
    ContentOption? edit,
  }) async {
    final ctCtl = TextEditingController(text: edit?.contentType ?? contentType ?? '');
    final fieldCtl = TextEditingController(text: edit?.field ?? field ?? 'type');
    final codeCtl = TextEditingController(text: edit?.code ?? '');
    final labelCtl = TextEditingController(text: edit?.label ?? '');
    final sortCtl =
        TextEditingController(text: (edit?.sortOrder ?? 0).toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(edit == null ? 'Thêm loại' : 'Sửa loại'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(ctCtl, 'Mục nội dung (content_type)',
                  hint: 'destinations, foods, hotels...'),
              _field(fieldCtl, 'Trường (field)',
                  hint: 'type, cuisine_type, vehicle...'),
              _field(codeCtl, 'Mã (code, lưu vào data)', hint: 'nature'),
              _field(labelCtl, 'Nhãn hiển thị', hint: 'Thiên nhiên'),
              _field(sortCtl, 'Thứ tự (số)'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu')),
        ],
      ),
    );
    if (saved != true) return;

    final repo = ref.read(contentOptionRepositoryProvider);
    final sort = int.tryParse(sortCtl.text.trim()) ?? 0;
    if (edit == null) {
      await repo.create(
        contentType: ctCtl.text.trim(),
        field: fieldCtl.text.trim(),
        code: codeCtl.text.trim(),
        label: labelCtl.text.trim(),
        sortOrder: sort,
      );
    } else {
      await repo.update(edit.id, {
        'content_type': ctCtl.text.trim(),
        'field': fieldCtl.text.trim(),
        'code': codeCtl.text.trim(),
        'label': labelCtl.text.trim(),
        'sort_order': sort,
      });
    }
    ref.invalidate(allContentOptionsProvider);
    ref.invalidate(contentOptionsProvider);
  }

  Widget _field(TextEditingController c, String label, {String? hint}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );
}

class _OptionChip extends StatelessWidget {
  final ContentOption option;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _OptionChip(
      {required this.option, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text('${option.label}  ·  ${option.code}',
          style: const TextStyle(fontSize: 12)),
      onPressed: onEdit,
      onDeleted: onDelete,
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }
}
