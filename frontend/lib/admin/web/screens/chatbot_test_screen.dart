// lib/admin/web/screens/chatbot_test_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/chatbot_test_repository.dart';

class _Msg {
  final String role; // user | assistant
  final String content;
  final String? meta; // intent · conf · sources · latency (assistant only)
  const _Msg(this.role, this.content, {this.meta});
}

class ChatbotTestScreen extends ConsumerStatefulWidget {
  const ChatbotTestScreen({super.key});

  @override
  ConsumerState<ChatbotTestScreen> createState() => _ChatbotTestScreenState();
}

class _ChatbotTestScreenState extends ConsumerState<ChatbotTestScreen> {
  final _ctl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _ctl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctl.text.trim();
    if (text.isEmpty || _loading) return;
    _ctl.clear();
    setState(() {
      _messages.add(_Msg('user', text));
      _loading = true;
    });
    _scrollToEnd();

    // history = các lượt trước (role/content), tối đa 10.
    final history = _messages
        .where((m) => m.content.isNotEmpty)
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();
    if (history.length > 10) history.removeRange(0, history.length - 10);

    try {
      final r = await ref.read(chatbotTestRepositoryProvider).ask(text, history);
      final answer = (r['answer'] ?? '').toString();
      final intent = r['intent']?.toString() ?? '—';
      final conf = r['confidence_score'];
      final sources = (r['sources'] as List?)?.length ?? 0;
      final lat = r['latency_ms'];
      final meta =
          'intent: $intent · độ tin: ${conf ?? '—'} · $sources nguồn · ${lat ?? '—'}ms';
      setState(() {
        _messages.add(_Msg('assistant',
            answer.isEmpty ? '(không có câu trả lời)' : answer,
            meta: meta));
      });
    } catch (e) {
      setState(() => _messages
          .add(_Msg('assistant', 'Lỗi: $e', meta: 'error')));
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Chatbot Test',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Thử chatbot RAG ngay trong panel (không lưu lịch sử)',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              if (_messages.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(_messages.clear),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Xoá hội thoại'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _messages.isEmpty
                  ? const Center(
                      child: Text('Nhập câu hỏi để test chatbot...',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _Bubble(msg: _messages[i]),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Hỏi chatbot... (vd: Phú Quốc có gì chơi?)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _send,
                style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14)),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 620),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isUser ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              msg.content,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            if (msg.meta != null) ...[
              const SizedBox(height: 6),
              Text(msg.meta!,
                  style: TextStyle(
                      fontSize: 11,
                      color: msg.meta == 'error'
                          ? Colors.red
                          : Colors.grey.shade600)),
            ],
          ],
        ),
      ),
    );
  }
}
