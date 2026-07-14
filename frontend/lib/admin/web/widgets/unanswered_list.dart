// lib/admin/web/widgets/unanswered_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/chat_management_provider.dart';
import '../../shared/data/chat_management_repository.dart';
import '../../shared/models/auth_user.dart';
import '../../shared/providers/auth_provider.dart';

class UnansweredList extends ConsumerWidget {
  final ValueChanged<String>? onSelect;
  const UnansweredList({super.key, this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(unansweredQuestionsProvider);
    final role = ref.watch(authProvider).user?.role;
    final canPromote =
        role == AdminRole.admin || role == AdminRole.superAdmin;

    return questionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(
            child: Text(
              'Không có câu hỏi chưa trả lời 🎉',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final q = questions[i];
            final isPromoted = q['is_promoted'] as bool? ?? false;
            final answer = q['answer'] as String? ?? '';
            final suggestion = q['suggestion'] as String? ?? '';
            final intent = q['intent'] as String? ?? '';
            final conf = (q['confidence_score'] as num?)?.toDouble();
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Câu hỏi THẬT của user
                  Text(
                    q['question'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  // Độ tin + intent
                  Row(
                    children: [
                      if (conf != null)
                        _Badge(
                          text: 'Độ tin ${(conf * 100).toStringAsFixed(0)}%',
                          color: conf < 0.2
                              ? Colors.red
                              : (conf < 0.5 ? Colors.orange : Colors.green),
                        ),
                      if (intent.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _Badge(text: intent, color: Colors.blueGrey),
                      ],
                    ],
                  ),
                  if (answer.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Bot trả lời: $answer',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                  if (suggestion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              size: 14, color: Color(0xFF7C3AED)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(suggestion,
                                style: const TextStyle(fontSize: 11.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (isPromoted || canPromote)
                    Row(
                      children: [
                        if (canPromote)
                          TextButton.icon(
                            onPressed: () => _resolve(context, ref,
                                q['answer_message_id'] as String?),
                            icon: const Icon(Icons.done_all, size: 14),
                            label: const Text('Đã xử lý',
                                style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              minimumSize: const Size(0, 30),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                          ),
                        const Spacer(),
                        // TP-005/008: AI soạn sẵn draft KB để admin duyệt/sửa
                        if (!isPromoted && canPromote) ...[
                          OutlinedButton.icon(
                            onPressed: () => _aiSuggest(context, ref,
                                q['id'] as String,
                                q['answer_message_id'] as String?),
                            icon: const Icon(Icons.auto_awesome, size: 14),
                            label: const Text('AI soạn draft',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF7C3AED),
                              minimumSize: const Size(0, 30),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        OutlinedButton.icon(
                          onPressed: isPromoted
                              ? null
                              : () => _promoteToKb(context, ref,
                                  q['id'] as String,
                                  q['answer_message_id'] as String?),
                          icon: Icon(
                            isPromoted ? Icons.check : Icons.add,
                            size: 14,
                          ),
                          label: Text(
                            isPromoted
                                ? 'Đã thêm vào KB'
                                : '+ Thêm vào KB',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _promoteToKb(BuildContext context, WidgetRef ref,
      String questionId, String? answerMessageId) async {
    try {
      await ref
          .read(chatRepositoryProvider)
          .promoteToKb(questionId, answerMessageId: answerMessageId);
      ref.invalidate(unansweredQuestionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã tạo Knowledge Entry draft!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    }
  }

  Future<void> _resolve(
      BuildContext context, WidgetRef ref, String? answerMessageId) async {
    if (answerMessageId == null) return;
    try {
      await ref.read(chatRepositoryProvider).resolveAnswer(answerMessageId);
      ref.invalidate(unansweredQuestionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đánh dấu xử lý xong')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    }
  }

  // ── TP-005/008: AI soạn draft → dialog duyệt/sửa → lưu vào KB ──────────────
  Future<void> _aiSuggest(BuildContext context, WidgetRef ref,
      String questionId, String? answerMessageId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Map<String, dynamic> res;
    try {
      res = await ref.read(chatRepositoryProvider).aiSuggestKb(questionId);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // đóng loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI không soạn được draft: $e')),
        );
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.pop(context); // đóng loading

    final draft = (res['draft'] as Map?)?.cast<String, dynamic>() ?? {};
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _AiDraftDialog(
        question: res['question']?.toString() ?? '',
        draft: draft,
        onSave: (edited) => ref.read(chatRepositoryProvider).promoteToKb(
            questionId,
            draft: edited,
            answerMessageId: answerMessageId),
      ),
    );
    if (saved == true && context.mounted) {
      ref.invalidate(unansweredQuestionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu Knowledge Entry từ draft AI!')),
      );
    }
  }
}

// Nhãn nhỏ hiển thị độ tin / intent
class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10.5, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog duyệt/sửa draft KB do AI soạn
// ─────────────────────────────────────────────────────────────────────────────
class _AiDraftDialog extends StatefulWidget {
  final String question;
  final Map<String, dynamic> draft;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _AiDraftDialog({
    required this.question,
    required this.draft,
    required this.onSave,
  });

  @override
  State<_AiDraftDialog> createState() => _AiDraftDialogState();
}

class _AiDraftDialogState extends State<_AiDraftDialog> {
  static const _categories = ['faq', 'destination', 'food', 'tips'];

  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl =
        TextEditingController(text: widget.draft['title']?.toString() ?? '');
    _contentCtrl =
        TextEditingController(text: widget.draft['content']?.toString() ?? '');
    final cat = widget.draft['category']?.toString() ?? 'faq';
    _category = _categories.contains(cat) ? cat : 'faq';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave({
        'title': _titleCtrl.text.trim(),
        'category': _category,
        'content': _contentCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi lưu: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowConfidence = widget.draft['confidence'] == 'low';
    return AlertDialog(
      title: const Row(children: [
        Icon(Icons.auto_awesome, size: 18, color: Color(0xFF7C3AED)),
        SizedBox(width: 8),
        Text('Draft KB do AI soạn', style: TextStyle(fontSize: 16)),
      ]),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Câu hỏi: "${widget.question}"',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              if (lowConfidence)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 14, color: Colors.orange),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'AI không chắc chắn về nội dung này — hãy kiểm chứng kỹ trước khi lưu.',
                        style: TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ]),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tiêu đề', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'faq'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentCtrl,
                maxLines: 12,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                    labelText: 'Nội dung (markdown)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save_outlined, size: 16),
          label: const Text('Lưu vào KB'),
        ),
      ],
    );
  }
}
