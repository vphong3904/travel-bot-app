import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/travel_api.dart';
import '../../theme/app_theme.dart';
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
    'Thời tiết Đà Lạt?',
    'Tour Phú Quốc',
    'Khách sạn Hội An',
    'Ẩm thực Hà Nội',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'ai',
      'text': 'Xin chào! Tôi là Trợ lý du lịch AI.\n\nTôi có thể tư vấn điểm đến, gợi ý lịch trình, tra cứu khách sạn và tour cho bạn!',
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
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
      final hasItinerary = lower.contains('lịch trình') || lower.contains('ngày');
      setState(() {
        _isGenerating = false;
        _messages.add({
          'sender': 'ai',
          'text': hasItinerary
              ? 'Tôi đã thiết kế lịch trình mẫu cho bạn. (Kết nối backend tại localhost:8000 để dùng RAG thật)'
              : 'Đây là câu trả lời mẫu. Khởi động backend FastAPI để trả lời từ Knowledge Base.',
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
                    {'day': 1, 'title': 'Ngày 1: Khởi hành', 'activities': ['Đáp sân bay', 'Grand World', 'Chợ đêm Dinh Cậu']},
                    {'day': 2, 'title': 'Ngày 2: Biển & Vui chơi', 'activities': ['Bãi Sao', 'VinWonders', 'Hải sản']},
                    {'day': 3, 'title': 'Ngày 3: Về nhà', 'activities': ['Nhà tù Phú Quốc', 'Mua quà', 'Trả phòng']},
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trợ Lý AI Du Lịch', style: AppTheme.heading(size: 16)),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _useMock ? AppColors.accent : AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(_useMock ? 'Demo Mode' : 'RAG Active', style: AppTheme.body(size: 11, color: AppColors.success, weight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _sendMessage(quickPrompts[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFE0F2FE)),
                    ),
                    child: Text(quickPrompts[i], style: AppTheme.body(size: 12, color: AppColors.primaryDark, weight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Hỏi về du lịch, lịch trình...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: IconButton(
                      onPressed: () => _sendMessage(_controller.text),
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 38),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            const SizedBox(width: 10),
            Text('AI đang suy nghĩ', style: AppTheme.body(size: 13, color: AppColors.muted, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['sender'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser ? const LinearGradient(colors: AppColors.primaryGradient) : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: isUser ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12)] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser && (msg['intent'] ?? '').isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0F2FE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(intentIcon(msg['intent']), size: 12, color: AppColors.primaryDark),
                          const SizedBox(width: 4),
                          Text(intentLabel(msg['intent']), style: AppTheme.body(size: 11, color: AppColors.primaryDark, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  Text(msg['text'], style: AppTheme.body(color: isUser ? Colors.white : AppColors.mid)),
                  if (msg['hasItinerary'] == true) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TripDetailsScreen(itinerary: msg['itinerary'])),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Xem Lịch Trình Chi Tiết', style: AppTheme.body(size: 13, color: Colors.white, weight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
