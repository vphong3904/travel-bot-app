import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/admin_api_service.dart';
import '../../widgets/common_widgets.dart';

class ChatLogsScreen extends StatefulWidget {
  const ChatLogsScreen({super.key});

  @override
  State<ChatLogsScreen> createState() => _ChatLogsScreenState();
}

class _ChatLogsScreenState extends State<ChatLogsScreen> {
  late AdminApiService _api;
  List<dynamic> logs = [];
  bool loading = true;
  String? filterIntent;

  @override
  void initState() {
    super.initState();
    final token = context.read<AppState>().token;
    _api = AdminApiService(token: token);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await _api.getChatLogs(intent: filterIntent);
      if (mounted) setState(() { logs = data; loading = false; });
    } catch (e) {
      if (mounted) setState(() { loading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log hội thoại', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                FilterChip(
                  label: const Text('Tất cả'),
                  selected: filterIntent == null,
                  onSelected: (_) {
                    setState(() => filterIntent = null);
                    _load();
                  },
                ),
                ...['faq_info', 'destination_advice', 'itinerary', 'service_search'].map((intent) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    label: Text(intentLabel(intent)),
                    selected: filterIntent == intent,
                    onSelected: (_) {
                      setState(() => filterIntent = intent);
                      _load();
                    },
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : logs.isEmpty
                    ? Center(child: Text('Chưa có log hội thoại', style: TextStyle(color: AppColors.muted)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: logs.length,
                        itemBuilder: (_, i) {
                          final log = logs[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(intentIcon(log['intent'] ?? ''), size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(intentLabel(log['intent'] ?? ''), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const Spacer(),
                                    Text(log['user_name'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                                  child: Text('👤 ${log['message']}', style: const TextStyle(fontSize: 13)),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                                  child: Text('🤖 ${(log['response'] ?? '').toString().substring(0, (log['response'] ?? '').toString().length.clamp(0, 200))}...', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
