// lib/admin/web/widgets/tag_editor.dart
import 'package:flutter/material.dart';

class TagEditor extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const TagEditor({super.key, required this.tags, required this.onChanged});

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showTagDialog(context),
      icon: const Icon(Icons.label_outline, size: 14),
      label: Text(
        widget.tags.isEmpty ? 'Tags' : widget.tags.join(', '),
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Future<void> _showTagDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    final current = List<String>.from(widget.tags);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Quản lý Tags'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (current.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: current
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style: const TextStyle(fontSize: 12)),
                              deleteIcon:
                                  const Icon(Icons.close, size: 14),
                              onDeleted: () =>
                                  setDialogState(() => current.remove(tag)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        autofocus: current.isEmpty,
                        decoration: const InputDecoration(
                          hintText: 'Thêm tag...',
                          isDense: true,
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            setDialogState(() {
                              current.add(v.trim());
                              ctrl.clear();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (ctrl.text.trim().isNotEmpty) {
                          setDialogState(() {
                            current.add(ctrl.text.trim());
                            ctrl.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () {
                widget.onChanged(List.from(current));
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
