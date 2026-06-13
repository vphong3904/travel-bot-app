import 'package:flutter/material.dart';
import '../../services/travel_api.dart';

/// Màn hình "Lịch sử trò chuyện" — danh sách các ChatSession của user
/// đang đăng nhập. Yêu cầu đã đăng nhập (có JWT trong TokenStorage).
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChatService.getSessions();
  }

  Future<void> _refresh() async {
    setState(() => _future = ChatService.getSessions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử trò chuyện')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final sessions = snapshot.data ?? [];
            if (sessions.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Chưa có lịch sử trò chuyện.\nĐăng nhập để lưu và xem lại các cuộc hội thoại.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = sessions[index] as Map<String, dynamic>;
                final title = (s['title'] as String?)?.isNotEmpty == true
                    ? s['title'] as String
                    : 'Cuộc hội thoại #${s['id']}';
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(s['updated_at']?.toString() ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await ChatService.deleteSession(s['id'] as int);
                      if (ok) _refresh();
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatSessionDetailScreen(sessionId: s['id'] as int, title: title),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Chi tiết 1 session: hiển thị toàn bộ message qua lại (chỉ xem lại,
/// không tiếp tục chat ở đây — muốn tiếp tục thì mở ChatbotScreen với
/// sessionId này để giữ ngữ cảnh).
class ChatSessionDetailScreen extends StatelessWidget {
  final int sessionId;
  final String title;

  const ChatSessionDetailScreen({super.key, required this.sessionId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: ChatService.getSessionDetail(sessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Không tải được nội dung session.'));
          }
          final messages = (data['messages'] as List<dynamic>? ?? []);
          if (messages.isEmpty) {
            return const Center(child: Text('Session chưa có tin nhắn nào.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final m = messages[index] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(left: 60),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m['message']?.toString() ?? ''),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(right: 60),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m['response']?.toString() ?? ''),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
