import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/app_state.dart';
import '../../services/chat_api_service.dart';
import '../../models/chat_session_model.dart';
import 'chatbot_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  late Future<List<ChatSessionModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    final appState = context.read<AppState>();
    // ✅ FIX: dùng TokenProvider để luôn lấy token mới nhất
    _historyFuture = appState.isLoggedIn
        ? ChatSessionApiService(
            tokenProvider: () => appState.token,
            tokenRefresher: () => appState.refreshAccessToken(),
          ).listSessions()
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Lịch sử hội thoại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _refreshHistory),
        ],
      ),
      body: FutureBuilder<List<ChatSessionModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refreshHistory, child: const Text('Thử lại')),
                ],
              ),
            );
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.muted),
                  SizedBox(height: 16),
                  Text('Bạn chưa có cuộc hội thoại nào.', style: TextStyle(color: AppColors.muted)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = history[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      session.displayTitle.isNotEmpty ? session.displayTitle[0].toUpperCase() : 'C',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    session.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    session.updatedAt != null ? session.updatedAt!.toLocal().toString().split('.').first : 'Mới tạo',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatBotScreen(sessionId: session.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}