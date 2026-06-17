import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/chat_message.dart';
import '../../services/chat_api_service.dart';
import '../../widgets/itinerary_card.dart';
import '../trip_detail/trip_details_screen.dart';

class ChatBotScreen extends StatefulWidget {
  final String? sessionId; // If provided, load existing session
  final String? initialMessage; // If provided, auto-send this message

  const ChatBotScreen({super.key, this.sessionId, this.initialMessage});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late ChatSessionApiService _api;
  late String _sessionId;
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

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
    final token = context.read<AppState>().token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Chưa đăng nhập';
      });
      return;
    }

    _api = ChatSessionApiService(token: token);
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      // If sessionId provided, load existing session; otherwise create new
      if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
        _sessionId = widget.sessionId!;
        await _loadMessages();
      } else {
        final session = await _api.createSession();
        _sessionId = session.id;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Auto-send initial message if provided
      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _sendMessage(widget.initialMessage!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Lỗi: ${e.toString()}';
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await _api.listMessages(_sessionId);
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (final m in msgs) {
          _messages.add(ChatMessage(
            sender: m.isUser ? 'user' : 'ai',
            text: m.content,
            sources: (m.sources as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
            intent: m.intent ?? '',
            confidence: m.promptTokens > 0 ? 0.95 : 0, // Approximate
          ));
        }
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Lỗi tải lịch sử: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final trimmed = text.trim();
    _controller.clear();

    // Add user message to UI
    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: trimmed));
    });
    _scrollToBottom();

    setState(() => _isSending = true);
    try {
      // Stream response from backend
      final stream = _api.sendMessageStream(_sessionId, trimmed);
      String fullContent = '';
      List<String> sources = [];

      await for (final event in stream) {
        if (!mounted) break;

        if (event['type'] == 'chunk') {
          fullContent += event['content'] ?? '';
          setState(() {
            if (_messages.isNotEmpty && _messages.last.sender == 'ai') {
              _messages.last = ChatMessage(sender: 'ai', text: fullContent);
            } else {
              _messages.add(ChatMessage(sender: 'ai', text: fullContent));
            }
          });
          _scrollToBottom();
        } else if (event['type'] == 'done') {
          sources = ((event['sources'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList();
        } else if (event['type'] == 'error') {
          throw Exception(event['detail'] ?? 'Lỗi từ server');
        }
      }

      // Add final message with sources
      if (!mounted) return;
      setState(() {
        if (_messages.isNotEmpty && _messages.last.sender == 'ai' && _messages.last.text == fullContent) {
          _messages.last = ChatMessage(
            sender: 'ai',
            text: fullContent,
            sources: sources,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          sender: 'ai',
          text: '❌ Lỗi: ${e.toString()}',
        ));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('Trợ Lý AI Du Lịch')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('Trợ Lý AI Du Lịch')),
        body: Center(child: Text('Lỗi: $_error')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Trợ Lý AI Du Lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text('Bắt đầu hội thoại!', style: TextStyle(color: AppColors.muted, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isSending && index == _messages.length) {
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
                                const SizedBox(width: 10),
                                Text('AI đang xử lý...', style: TextStyle(color: AppColors.muted, fontSize: 13)),
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
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: 'Hỏi về du lịch, điểm đến, lịch trình...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _isSending ? null : _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _isSending ? AppColors.muted : AppColors.primary,
                    child: IconButton(
                      icon: Icon(_isSending ? Icons.hourglass_bottom : Icons.send, color: Colors.white, size: 20),
                      onPressed: _isSending ? null : () => _sendMessage(_controller.text),
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
}
