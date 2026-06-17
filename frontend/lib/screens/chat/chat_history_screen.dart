import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/app_state.dart';
import '../../services/travel_api_service.dart';
import 'chatbot_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    final userId = context.read<AppState>().user?.id ?? '';
    setState(() {
      _historyFuture = ChatService.getUserHistory(userId);
    });
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
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || (snapshot.data == null)) {
            return const Center(child: Text('Không thể tải lịch sử', style: TextStyle(color: AppColors.muted)));
          }

          final history = snapshot.data!;
          if (history.isEmpty) {
            return const Center(child: Text('Bạn chưa có cuộc hội thoại nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = history[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(intentIcon(item['intent'] ?? ''), color: AppColors.primary, size: 20),
                  ),
                  title: Text(item['message'] ?? '...', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(item['timestamp'] ?? '', style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatBotScreen(initialMessage: item['message']?.toString())));
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