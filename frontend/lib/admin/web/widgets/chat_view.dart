// lib/admin/web/widgets/chat_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/chat_management_provider.dart';
import '../../shared/data/chat_management_repository.dart';
import '../../shared/models/auth_user.dart';
import '../../shared/providers/auth_provider.dart';
import 'chat_bubble.dart';

class ChatView extends ConsumerWidget {
  final String sessionId;
  final VoidCallback onClose;

  const ChatView(
      {super.key, required this.sessionId, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync =
        ref.watch(chatSessionMessagesProvider(sessionId));
    final role = ref.watch(authProvider).user?.role;
    final canModerate =
        role == AdminRole.admin || role == AdminRole.superAdmin;

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        final session = data.session;
        final messages = data.messages;
        final isFlagged = session['is_flagged'] as bool? ?? false;

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 18),
                    onPressed: onClose,
                    tooltip: 'Đóng',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['title'] as String? ??
                              'Hội thoại không tên',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${messages.length} tin nhắn',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (canModerate) ...[
                    OutlinedButton.icon(
                      onPressed: () => ref
                          .read(chatRepositoryProvider)
                          .updateSession(sessionId,
                              isFlagged: !isFlagged)
                          .then((_) => ref.invalidate(
                              chatSessionMessagesProvider(sessionId))),
                      icon: const Text('🚩'),
                      label:
                          Text(isFlagged ? 'Bỏ đánh dấu' : 'Đánh dấu'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isFlagged ? Colors.red : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, i) =>
                    ChatBubble(message: messages[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}
