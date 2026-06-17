import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/chat_message.dart';
import '../services/chat_service.dart';
import '../../widgets/itinerary_card.dart';
import '../trip_detail/trip_details_screen.dart';

class ChatBotScreen extends StatefulWidget {
  final bool autoPrompt;
  final String? initialMessage;

  const ChatBotScreen({super.key, this.autoPrompt = false, this.initialMessage});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late ChatService _chatService;
  bool _isConnected = false;
  bool _isTyping = false;

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
    
    final appState = context.read<AppState>();
    _chatService = ChatService(
      userId: appState.user?.id ?? '',
      userName: appState.user?.displayName ?? 'Khách',
    );

    _chatService.messages.listen((msg) {
      if (!mounted) return;
      setState(() => _messages.add(msg));
      _scrollToBottom();
    });

    _chatService.typingStream.listen((typing) {
      if (!mounted) return;
      setState(() => _isTyping = typing);
      if (typing) _scrollToBottom();
    });

    _chatService.connectionState.listen((state) {
      if (!mounted) return;
      setState(() => _isConnected = state == ChatConnectionState.connected);
    });

    _chatService.connect();

    _messages.add(const ChatMessage(
      sender: 'ai',
      text: 'Xin chào! Tôi là Trợ lý du lịch AI 🤖\nTôi có thể tư vấn điểm đến và lên lịch trình RAG!',
    ));

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
    _chatService.dispose();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final sent = _chatService.send(text);
    _controller.clear();
    if (!sent) _chatService.connect();
    _scrollToBottom();
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
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _isConnected ? AppColors.success : Colors.orange, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(_isConnected ? 'RAG Active' : 'Connecting...', style: TextStyle(fontSize: 11, color: AppColors.muted)),
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
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
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
                final isUser = msg.sender == 'user';
                final sources = msg.sources;
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
                        if (!isUser && (msg.intent).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(intentIcon(msg.intent), size: 14, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(intentLabel(msg.intent), style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          
                        Text(msg.text, style: TextStyle(color: isUser ? Colors.white : AppColors.dark, height: 1.5)),
                                if (!isUser && (msg.confidence) > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Độ tin cậy: ${(msg.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 11, color: AppColors.muted),
                          ),
                        ],

                        if (!isUser && sources.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: sources.map((source) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(source, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                              );
                            }).toList(),
                          ),
                        ],
                        if (msg.hasItinerary && msg.itinerary != null) ...[
                          ItineraryCard(itinerary: Map<String, dynamic>.from(msg.itinerary!)),
                        ],
                        if (msg.hasItinerary) ...[
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TripDetailsScreen(itinerary: msg.itinerary)),
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
