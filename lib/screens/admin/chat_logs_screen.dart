import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/web_layout.dart';

class ChatLogsScreen extends StatefulWidget {
  const ChatLogsScreen({super.key});

  @override
  State<ChatLogsScreen> createState() => _ChatLogsScreenState();
}

class _ChatLogsScreenState extends State<ChatLogsScreen> {
  List<dynamic> logs = [];
  List<dynamic> filtered = [];
  bool loading = true;
  String? filterIntent;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await AdminService.getChatLogs(intent: filterIntent);
    if (mounted) {
      setState(() {
        logs = data;
        _applyFilter();
        loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    filtered = logs.where((log) {
      if (q.isEmpty) return true;
      final text = '${log['message']} ${log['response']} ${log['user_name']}'.toLowerCase();
      return text.contains(q);
    }).toList();
  }

  String _preview(String? text, {int max = 220}) {
    final value = text ?? '';
    if (value.length <= max) return value;
    return '${value.substring(0, max)}...';
  }

  @override
  Widget build(BuildContext context) {
    return WebAdminShell(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(title: Text('Log hội thoại', style: AppTheme.heading(size: 18))),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Tìm tin nhắn, phản hồi AI...',
                margin: EdgeInsets.zero,
                onChanged: (_) => setState(_applyFilter),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  FilterChip(
                    label: const Text('Tất cả'),
                    selected: filterIntent == null,
                    onSelected: (_) { filterIntent = null; _load(); },
                  ),
                  ...['faq_info', 'destination_advice', 'itinerary', 'service_search'].map((intent) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(intentLabel(intent)),
                          selected: filterIntent == intent,
                          onSelected: (_) { filterIntent = intent; _load(); },
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filtered.isEmpty
                      ? Center(child: Text('Chưa có log hội thoại', style: AppTheme.body(color: AppColors.muted)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final log = filtered[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(intentIcon(log['intent'] ?? ''), size: 16, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text(intentLabel(log['intent'] ?? ''), style: AppTheme.body(size: 12, weight: FontWeight.w700)),
                                      const Spacer(),
                                      Text(log['user_name'] ?? '', style: AppTheme.body(size: 11, color: AppColors.muted)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(log['message'] ?? '', style: AppTheme.body(size: 13))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.support_agent_rounded, size: 16, color: AppColors.muted),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(_preview(log['response']), style: AppTheme.body(size: 13, color: AppColors.muted))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
