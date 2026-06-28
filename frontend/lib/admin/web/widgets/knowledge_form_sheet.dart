// lib/admin/web/widgets/knowledge_form_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/knowledge_entry.dart';
import '../../shared/data/knowledge_repository.dart';
import 'embedding_status_badge.dart';

class KnowledgeFormSheet extends ConsumerStatefulWidget {
  final bool open;
  final KnowledgeEntry? entry;
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  const KnowledgeFormSheet({
    super.key,
    required this.open,
    required this.entry,
    required this.onClose,
    required this.onSuccess,
  });

  @override
  ConsumerState<KnowledgeFormSheet> createState() =>
      _KnowledgeFormSheetState();
}

class _KnowledgeFormSheetState extends ConsumerState<KnowledgeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _sourceCtrl;
  late List<String> _tags;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _contentCtrl = TextEditingController(text: e?.content ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _sourceCtrl = TextEditingController(text: e?.source ?? '');
    _tags = List<String>.from(e?.tags ?? []);
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _categoryCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.entry != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(knowledgeRepositoryProvider);
      final data = {
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'category': _categoryCtrl.text.trim().isEmpty
            ? null
            : _categoryCtrl.text.trim(),
        'tags': _tags,
        'source': _sourceCtrl.text.trim().isEmpty
            ? null
            : _sourceCtrl.text.trim(),
        'is_active': _isActive,
      };
      final KnowledgeEntry result;
      if (_isEdit) {
        result = await repo.update(widget.entry!.id, data);
      } else {
        result = await repo.create(data);
      }
      widget.onSuccess();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.embeddingStatus == 'pending'
              ? 'Đã lưu! Đang tạo embedding...'
              : _isEdit
                  ? 'Cập nhật thành công'
                  : 'Tạo thành công'),
        ));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox.shrink();
    return Container(
      width: 560,
      decoration: BoxDecoration(
        color: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(
                  _isEdit ? 'Chỉnh sửa Entry' : 'Thêm Knowledge Entry',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose),
              ],
            ),
          ),

          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Tiêu đề *'),
                    TextFormField(
                      controller: _titleCtrl,
                      validator: (v) =>
                          (v == null || v.trim().length < 3)
                              ? 'Tối thiểu 3 ký tự'
                              : null,
                      decoration: _inputDeco('Nhập tiêu đề...'),
                    ),
                    const SizedBox(height: 16),
                    _label('Nội dung *'),
                    TextFormField(
                      controller: _contentCtrl,
                      maxLines: 8,
                      validator: (v) =>
                          (v == null || v.trim().length < 10)
                              ? 'Tối thiểu 10 ký tự'
                              : null,
                      decoration: _inputDeco('Nhập nội dung...'),
                    ),
                    const SizedBox(height: 16),
                    _label('Category'),
                    TextFormField(
                      controller: _categoryCtrl,
                      decoration:
                          _inputDeco('faq, policy, destination...'),
                    ),
                    const SizedBox(height: 16),
                    _label('Tags'),
                    TagInputField(
                      tags: _tags,
                      onChanged: (t) => setState(() => _tags = t),
                    ),
                    const SizedBox(height: 16),
                    _label('Nguồn (URL)'),
                    TextFormField(
                      controller: _sourceCtrl,
                      decoration:
                          _inputDeco('vietnamtourism.gov.vn'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Switch(
                          value: _isActive,
                          onChanged: (v) =>
                              setState(() => _isActive = v),
                        ),
                        const SizedBox(width: 8),
                        const Text('Kích hoạt'),
                      ],
                    ),
                    if (_isEdit && widget.entry != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Embedding: ',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13)),
                                EmbeddingStatusBadge(
                                  status:
                                      widget.entry!.embeddingStatus,
                                  jobId: widget.entry!.embeddingJobId,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Khi bạn lưu thay đổi tiêu đề hoặc nội dung, hệ thống sẽ tự động tạo embedding mới.',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                    onPressed: widget.onClose,
                    child: const Text('Huỷ')),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13)),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)),
      );
}

class TagInputField extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const TagInputField(
      {super.key, required this.tags, required this.onChanged});

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _ctrl.text.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      widget.onChanged([...widget.tags, tag]);
      _ctrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...widget.tags.map((tag) => Chip(
                label: Text(tag,
                    style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () {
                  final newTags = List<String>.from(widget.tags)
                    ..remove(tag);
                  widget.onChanged(newTags);
                },
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4),
              )),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: 'Thêm tag...',
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 4),
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (_) => _addTag(),
            ),
          ),
        ],
      ),
    );
  }
}
