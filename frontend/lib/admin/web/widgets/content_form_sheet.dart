// lib/admin/web/widgets/content_form_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/content_repository.dart';
import '../../shared/models/content_item.dart';

class ContentFormField {
  final String key;
  final String label;
  final bool required;
  final int maxLines;
  final List<String>? options;

  const ContentFormField({
    required this.key,
    required this.label,
    this.required = false,
    this.maxLines = 1,
    this.options,
  });
}

class ContentFormSheet extends ConsumerStatefulWidget {
  final bool open;
  final ContentItem? item;
  final String contentType;
  final String citySlug;
  final List<ContentFormField> formFields;
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  const ContentFormSheet({
    super.key,
    required this.open,
    this.item,
    required this.contentType,
    required this.citySlug,
    required this.formFields,
    required this.onClose,
    required this.onSuccess,
  });

  @override
  ConsumerState<ContentFormSheet> createState() =>
      _ContentFormSheetState();
}

class _ContentFormSheetState
    extends ConsumerState<ContentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _dropdownValues = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    for (final f in widget.formFields) {
      final existing = widget.item?.getString(f.key) ??
          (widget.item?.data[f.key]?.toString() ?? '');
      if (f.options != null) {
        _dropdownValues[f.key] =
            existing.isEmpty ? null : existing;
      } else {
        _controllers[f.key] =
            TextEditingController(text: existing);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final data = <String, dynamic>{};
      for (final f in widget.formFields) {
        if (f.options != null) {
          data[f.key] = _dropdownValues[f.key];
        } else {
          data[f.key] = _controllers[f.key]?.text ?? '';
        }
      }
      final repo = ref.read(contentRepositoryProvider);
      if (widget.item == null) {
        await repo.create(
          contentType: widget.contentType,
          citySlug: widget.citySlug,
          data: data,
        );
      } else {
        await repo.update(
          contentType: widget.contentType,
          itemId: widget.item!.id,
          data: data,
        );
      }
      widget.onSuccess();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.item == null;
    return Container(
      width: 520,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(
                  isNew
                      ? 'Thêm mới'
                      : 'Chỉnh sửa',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: widget.formFields.map((f) {
                  if (f.options != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        initialValue: _dropdownValues[f.key],
                        decoration: InputDecoration(
                          labelText: f.required
                              ? '${f.label} *'
                              : f.label,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: f.options!
                            .map((o) => DropdownMenuItem(
                                  value: o,
                                  child: Text(o,
                                      style: const TextStyle(
                                          fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(
                            () => _dropdownValues[f.key] = v),
                        validator: f.required
                            ? (v) => v == null
                                ? 'Bắt buộc'
                                : null
                            : null,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _controllers[f.key],
                      maxLines: f.maxLines,
                      decoration: InputDecoration(
                        labelText:
                            f.required ? '${f.label} *' : f.label,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: f.required
                          ? (v) => (v == null || v.isEmpty)
                              ? 'Bắt buộc'
                              : null
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onClose,
                  child: const Text('Huỷ'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : const Text('Lưu'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
