import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/travel_api.dart';
import '../../widgets/common_widgets.dart';
import '../trip_detail/trip_details_screen.dart';

class ChatBotScreen extends StatefulWidget {
  final bool autoPrompt;
  final String? initialMessage;

  const ChatBotScreen({super.key, this.autoPrompt = false, this.initialMessage});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isGenerating = false;
  bool _useMock = false;

  final quickPrompts = [
    'Thời tiết Đà Lạt tháng 12?',
    'Gợi ý điểm đến biển ngân sách tầm trung',
    'Lịch trình Phú Quốc 3 ngày 2 đêm gia đình',
    'Tìm khách sạn Phú Quốc giá rẻ',
    'Ẩm thực Hà Giang có gì đặc sắc?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'ai',
      'text': 'Xin chào! Tôi là Trợ lý du lịch AI 🤖\n\nTôi có thể:\n• Trả lời thông tin du lịch (FAQ)\n• Tư vấn điểm đến phù hợp\n• Gợi ý lịch trình\n• Tra cứu khách sạn, tour, vé\n\nHệ thống RAG + NLP đang hoạt động!',
      'hasItinerary': false,
      'intent': '',
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoPrompt) {
        _sendMessage('Lên kế hoạch đi Phú Quốc 3 ngày 2 đêm giúp tôi.');
      } else if (widget.initialMessage != null) {
        _sendMessage(widget.initialMessage!);
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text, 'hasItinerary': false});
      _isGenerating = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final appState = context.read<AppState>();
      final res = await ChatService.sendMessage(
        message: text,
        userId: appState.user?.id ?? 0,
        userName: appState.user?.name ?? 'Khách',
      );
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _messages.add({
          'sender': 'ai',
          'text': res['text'] ?? '',
          'hasItinerary': res['has_itinerary'] ?? false,
          'intent': res['intent'] ?? '',
          'itinerary': res['itinerary'],
          'sources': res['sources'] ?? [],
        });
      });
    } catch (_) {
      _useMock = true;
      _sendMockResponse(text);
    }
    _scrollToBottom();
  }

  void _sendMockResponse(String text) {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final lower = text.toLowerCase();
      bool hasItinerary = lower.contains('lịch trình') || lower.contains('ngày');
      setState(() {
        _isGenerating = false;
        _messages.add({
          'sender': 'ai',
          'text': hasItinerary
              ? '✨ Demo mode: Tôi đã thiết kế lịch trình mẫu cho bạn. (Kết nối backend tại localhost:8000 để dùng RAG thật)'
              : '🔍 Demo mode: Đây là câu trả lời mẫu. Khởi động backend FastAPI để trả lời từ Knowledge Base.',
          'hasItinerary': hasItinerary,
          'intent': hasItinerary ? 'itinerary' : 'faq_info',
          'itinerary': hasItinerary
              ? {
                  'destination': 'Phú Quốc',
                  'duration': '3 ngày 2 đêm',
                  'group': 'gia đình',
                  'budget_low': 4000000,
                  'budget_high': 10000000,
                  'days': [
                    {'day': 1, 'title': 'Ngày 1', 'activities': ['Đáp sân bay', 'Grand World', 'Chợ đêm Dinh Cậu']},
                    {'day': 2, 'title': 'Ngày 2', 'activities': ['Bãi Sao', 'VinWonders']},
                    {'day': 3, 'title': 'Ngày 3', 'activities': ['Nhà tù Phú Quốc', 'Về']},
                  ],
                }
              : null,
        });
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trợ Lý AI Du Lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _useMock ? AppColors.secondary : AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(_useMock ? 'Demo Mode' : 'RAG Active', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_messages.length <= 1)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: quickPrompts.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(quickPrompts[i], style: const TextStyle(fontSize: 12)),
                    onPressed: () => _sendMessage(quickPrompts[i]),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                          SizedBox(width: 10),
                          Text('AI đang suy nghĩ...', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: isUser ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser && (msg['intent'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(intentIcon(msg['intent']), size: 14, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(intentLabel(msg['intent']), style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        Text(msg['text'], style: TextStyle(color: isUser ? Colors.white : AppColors.dark, height: 1.5)),
                        if (msg['hasItinerary'] == true) ...[
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TripDetailsScreen(itinerary: msg['itinerary'])),
                            ),
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Xem Lịch Trình Chi Tiết'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Hỏi về du lịch, điểm đến, lịch trình...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: () => _sendMessage(_controller.text)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
