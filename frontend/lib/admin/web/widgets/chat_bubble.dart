// lib/admin/web/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import '../../shared/models/chat_session_item.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessageModel message;
  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showSources = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final msg = widget.message;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  size: 16, color: Colors.white),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),

                // RAG metadata — chỉ cho assistant
                if (!isUser) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (msg.intent != null)
                        _metaBadge(msg.intent!, Colors.purple.shade100,
                            Colors.purple.shade700),
                      if (msg.confidenceScore != null)
                        _metaBadge(
                          'conf: ${(msg.confidenceScore! * 100).toStringAsFixed(0)}%',
                          msg.confidenceScore! > 0.7
                              ? Colors.green.shade100
                              : msg.confidenceScore! > 0.5
                                  ? Colors.orange.shade100
                                  : Colors.red.shade100,
                          msg.confidenceScore! > 0.7
                              ? Colors.green.shade700
                              : msg.confidenceScore! > 0.5
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700,
                        ),
                      if (msg.cacheHit != null)
                        _metaBadge(
                          'cache: ${msg.cacheHit}',
                          Colors.teal.shade50,
                          Colors.teal.shade700,
                        ),
                      if (msg.latencyMs != null)
                        _metaBadge(
                          '${msg.latencyMs}ms',
                          Colors.grey.shade100,
                          Colors.grey.shade600,
                        ),
                    ],
                  ),

                  // Sources collapsible
                  if (msg.sources?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showSources = !_showSources),
                      child: Text(
                        '${msg.sources!.length} nguồn ${_showSources ? "▴" : "▾"}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    if (_showSources)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                                color: Colors.grey.shade300, width: 2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: msg.sources!
                              .map((src) => Text(
                                    '${src['city_slug'] ?? src['category'] ?? '—'}'
                                    '${src['score'] != null ? " · ${(src['score'] as num).toStringAsFixed(2)}" : ""}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _metaBadge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, color: fg)),
      );
}
