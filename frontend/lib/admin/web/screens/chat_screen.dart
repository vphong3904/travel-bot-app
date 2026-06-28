// lib/admin/web/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/session_list.dart';
import '../widgets/chat_view.dart';
import '../widgets/unanswered_list.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Cột trái — 360px
        SizedBox(
          width: 360,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Hội thoại'),
                      Tab(text: 'Chưa trả lời'),
                      Tab(text: 'Đánh dấu'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SessionList(
                        selectedId: _selectedSessionId,
                        onSelect: (id) =>
                            setState(() => _selectedSessionId = id),
                      ),
                      UnansweredList(
                        onSelect: (id) =>
                            setState(() => _selectedSessionId = id),
                      ),
                      SessionList(
                        selectedId: _selectedSessionId,
                        onSelect: (id) =>
                            setState(() => _selectedSessionId = id),
                        filterFlagged: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cột phải — flex
        Expanded(
          child: _selectedSessionId != null
              ? ChatView(
                  sessionId: _selectedSessionId!,
                  onClose: () =>
                      setState(() => _selectedSessionId = null),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Chọn một hội thoại để xem chi tiết',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
