// ─────────────────────────────────────────────────────────────────────────────
// HƯỚNG DẪN TÍCH HỢP ChatService vào main.dart
//
// 1. Thêm dependency vào pubspec.yaml:
//      web_socket_channel: ^3.0.1
//
// 2. Thêm import ở đầu main.dart:
//      import 'services/chat_service.dart';
//
// 3. Thay toàn bộ class _ChatBotScreenState bằng đoạn code bên dưới.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:frontend/screens/chat/chatbot_screen.dart';
import 'package:frontend/screens/services/chat_service.dart';

class _ChatBotScreenState extends State<ChatBotScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatService _chatService;

  bool _isTyping = false; // AI đang phản hồi
  bool _isConnected = false;

  // ── Init / Dispose ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // ── Khởi tạo service với user hiện tại ────────────────────────────────
    // TODO: thay userId/userName bằng giá trị từ auth state thực tế
    _chatService = ChatService(userId: 0, userName: 'Khách');

    // ── Lắng nghe tin nhắn đến ────────────────────────────────────────────
    _chatService.messages.listen((msg) {
      if (!mounted) return;
      setState(() {
        _messages.add(msg);
      });
      _scrollToBottom();
    });

    // ── Lắng nghe typing indicator ────────────────────────────────────────
    _chatService.typingStream.listen((typing) {
      if (!mounted) return;
      setState(() {
        _isTyping = typing;
      });
      if (typing) _scrollToBottom();
    });

    // ── Lắng nghe trạng thái kết nối ─────────────────────────────────────
    _chatService.connectionState.listen((state) {
      if (!mounted) return;
      setState(() {
        _isConnected = state == ChatConnectionState.connected;
      });
    });

    // ── Tin nhắn chào mừng (local, không qua backend) ─────────────────────
    _messages.add(const ChatMessage(
      sender: 'ai',
      text:
          'Xin chào! Tôi là Trợ lý du lịch AI thông minh 🤖. '
          'Tôi có thể tư vấn điểm đến, ẩm thực, khách sạn '
          'hoặc lên lịch trình chi tiết cho chuyến đi của bạn. '
          'Bạn muốn đi đâu nhỉ?',
    ));

    // ── Kết nối WebSocket ─────────────────────────────────────────────────
    _chatService.connect();

    // ── Auto-send nếu được kích hoạt từ form cấu hình ─────────────────────
    if (widget.autoPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage('Lên kế hoạch đi Phú Quốc 3 ngày 2 đêm, ngân sách Tầm trung từ Hồ Chí Minh giúp tôi.');
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  // ── Gửi tin nhắn ──────────────────────────────────────────────────────────

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    final sent = _chatService.send(text);
    if (!sent) {
      // Chưa kết nối → thông báo
      setState(() {
        _messages.add(ChatMessage.error('⚠️ Chưa kết nối server. Đang thử lại...'));
      });
      _chatService.connect(); // thử kết nối lại
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE3F2FD),
              child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF4A90E2)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trợ Lý AI Du Lịch',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: _isConnected ? Colors.green : Colors.orange,
                    ),
                    Text(
                      _isConnected ? ' Trực tuyến (RAG active)' : ' Đang kết nối...',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        actions: [
          if (_isTyping)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
              tooltip: 'Dừng phản hồi',
              onPressed: () => setState(() => _isTyping = false),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Danh sách tin nhắn ───────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Typing bubble cuối danh sách
                if (_isTyping && index == _messages.length) {
                  return _buildTypingBubble();
                }
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // ── Quick chips ──────────────────────────────────────────────────
          _buildQuickChipsRow(),

          // ── Input bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Hỏi về thời tiết, chi phí, ẩm thực...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF4A90E2),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(_controller.text),
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

  // ── Bubble builders ────────────────────────────────────────────────────────

  Widget _buildChatBubble(ChatMessage msg) {
    final isUser = msg.sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            // Nút xem lịch trình chi tiết
            if (msg.hasItinerary) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: navigate tới màn hình ItineraryDashboard
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => ItineraryDashboard(data: msg.itinerary!),
                  // ));
                },
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text('Xem lịch trình chi tiết'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90E2),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            // Badge intent (debug / info)
            if (!isUser && msg.intent.isNotEmpty && msg.intent != 'error') ...[
              const SizedBox(height: 6),
              Text(
                '🏷 ${msg.intent}  •  ${(msg.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI đang phân tích...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChipsRow() {
    const suggestions = [
      '📍 Điểm đến hot',
      '🏨 Khách sạn Đà Lạt',
      '✈️ Lịch trình Hà Nội',
      '💰 Chi phí Phú Quốc',
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ActionChip(
          label: Text(suggestions[index], style: const TextStyle(fontSize: 12)),
          onPressed: () => _sendMessage(suggestions[index]),
          backgroundColor: const Color(0xFFE3F2FD),
        ),
      ),
    );
  }
}