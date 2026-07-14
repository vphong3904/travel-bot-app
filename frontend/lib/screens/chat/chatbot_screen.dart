import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/markdown_chat.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/chat_message.dart';
import '../../services/chat_api_service.dart';
import '../../services/chat_stream_utils.dart';
import '../../services/trip_api_service.dart';
import '../../services/api_service.dart';
import '../../widgets/itinerary_card.dart';
import '../../widgets/trip_plan_view.dart';
import '../../widgets/trip_plan_swap.dart';
import '../trip_detail/trip_details_screen.dart';
import '../auth/login_register_screen.dart';
import '../../services/sse_client.dart';

// ── Giới hạn câu hỏi cho khách ─────────────────────────────────────────────
const _kGuestMaxQuestions = 3;
const _kGuestCountKey = 'guest_ai_question_count';
const _kGuestDateKey  = 'guest_ai_question_date';

class ChatBotScreen extends StatefulWidget {
  final String? sessionId;
  final String? initialMessage;
  /// Khi là tab trong bottom navigation → không có nút back, chừa chỗ cho
  /// thanh nav dưới (Req 3). Khi push fullscreen (mở 1 session cụ thể) = false.
  final bool embedded;

  const ChatBotScreen({
    super.key,
    this.sessionId,
    this.initialMessage,
    this.embedded = false,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late ChatSessionApiService _api;
  // Lazy: null cho tới khi thật sự gửi tin nhắn đầu tiên — tránh tạo session
  // rỗng mỗi lần mở màn (bug cũ: mở màn là tạo, thoát/vào lại tạo thêm cái mới).
  String? _sessionId;
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  // Guest mode
  bool _isGuest = false;
  int _guestQuestionCount = 0;

  final quickPrompts = [
    'Thời tiết Đà Lạt tháng 12?',
    'Gợi ý điểm đến biển tầm trung',
    'Lịch trình Phú Quốc 3N2Đ',
    'Khách sạn Phú Quốc giá rẻ',
    'Ẩm thực Hà Giang đặc sắc?',
  ];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();

    if (!appState.isLoggedIn) {
      // Chế độ khách: cho phép hỏi tối đa _kGuestMaxQuestions câu
      _isGuest = true;
      _loadGuestCount().then((_) {
        if (mounted) setState(() => _isLoading = false);
        // Nếu có initialMessage và còn quota → gửi luôn
        if (mounted && widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _sendMessage(widget.initialMessage!));
        }
      });
      return;
    }

    _api = ChatSessionApiService(
      tokenProvider: () => appState.token,
      tokenRefresher: () => appState.refreshAccessToken(),
    );
    _initSession();
  }

  // ── Guest quota helpers ─────────────────────────────────────────────────

  Future<void> _loadGuestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_kGuestDateKey) ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (savedDate != today) {
      // Ngày mới → reset đếm
      await prefs.setInt(_kGuestCountKey, 0);
      await prefs.setString(_kGuestDateKey, today);
    }
    _guestQuestionCount = prefs.getInt(_kGuestCountKey) ?? 0;
  }

  Future<void> _incrementGuestCount() async {
    _guestQuestionCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGuestCountKey, _guestQuestionCount);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_kGuestDateKey, today);
  }

  int get _guestRemaining => (_kGuestMaxQuestions - _guestQuestionCount).clamp(0, _kGuestMaxQuestions);
  bool get _guestLimitReached => _isGuest && _guestQuestionCount >= _kGuestMaxQuestions;

  Future<void> _initSession() async {
    try {
      if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
        _sessionId = widget.sessionId!;
        await _loadMessages();
      }
      // Không truyền sessionId (mở màn chat mới) → KHÔNG tạo session ở đây.
      // Session chỉ được tạo lazy trong _sendMessage() khi người dùng thật sự
      // gửi tin nhắn đầu tiên, để tránh sinh session rỗng không tên.

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _sendMessage(widget.initialMessage!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = friendlyError(e);
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await _api.listMessages(_sessionId!);
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (final m in msgs) {
          _messages.add(ChatMessage(
            sender: m.isUser ? 'user' : 'ai',
            text: m.content,
            sources: (m.sources as List<dynamic>?)
                    ?.map((e) => SourceRef.fromDynamic(e))
                    .toList() ??
                [],
            intent: m.intent ?? '',
            confidence: m.confidenceScore ?? 0,
            suggestedQuestions: m.suggestedQuestions,
            messageId: m.id,
            feedback: m.feedback ?? 0,
          ));
        }
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Lỗi tải lịch sử: ${friendlyError(e)}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    // Khách đã hết quota → hiện dialog mời đăng nhập
    if (_guestLimitReached) {
      _showGuestLimitDialog();
      return;
    }

    final trimmed = text.trim();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: trimmed));
      _isSending = true;
    });
    _scrollToBottom();

    // Nếu là khách → gọi AI qua Gemini trực tiếp (không cần session)
    if (_isGuest) {
      await _sendGuestMessage(trimmed);
      return;
    }

    try {
      // Tạo session lazy đúng lúc gửi tin nhắn đầu tiên (nếu chưa có).
      _sessionId ??= (await _api.createSession()).id;
      final stream = _api.sendMessageStream(_sessionId!, trimmed);
      String fullContent = '';
      List<SourceRef> sources = [];
      Map<String, dynamic>? itinerary;
      bool hasItinerary = false;
      String aiIntent = '';
      double aiConfidence = 0;
      List<String> suggested = [];
      String? aiMessageId;

      await for (final event in stream) {
        if (!mounted) break;

        if (event['type'] == 'chunk') {
          final rawContent = event['content'] as String? ?? '';
          final parsed = parseChatChunkContent(rawContent);
          fullContent += parsed['text'] as String;

          if (parsed['sources'] != null) {
            sources = (parsed['sources'] as List)
                .map((e) => SourceRef.fromDynamic(e))
                .toList();
          }
          if (parsed['itinerary'] != null) {
            itinerary = parsed['itinerary'] as Map<String, dynamic>;
            hasItinerary = true;
          }

          setState(() {
            if (_messages.isNotEmpty && _messages.last.sender == 'ai') {
              _messages.last = ChatMessage(
                sender: 'ai',
                text: fullContent,
                sources: sources,
                hasItinerary: hasItinerary,
                itinerary: itinerary,
              );
            } else {
              _messages.add(ChatMessage(sender: 'ai', text: fullContent));
            }
          });
          _scrollToBottom();

        } else if (event['type'] == 'done') {
          final doneSources = (event['sources'] as List<dynamic>?)
              ?.map((e) => SourceRef.fromDynamic(e))
              .toList();
          if (doneSources != null && doneSources.isNotEmpty) {
            sources = doneSources;
          }
          if (event['itinerary'] != null) {
            itinerary = event['itinerary'] as Map<String, dynamic>;
            hasItinerary = true;
          }
          // [P0] intent + độ tin cậy + câu gợi ý thật từ backend
          aiIntent = event['intent']?.toString() ?? '';
          aiConfidence = (event['confidence_score'] as num?)?.toDouble() ?? 0;
          aiMessageId = event['message_id']?.toString();
          suggested = (event['suggested_questions'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();
          if (event['content'] != null) {
            final parsed = parseChatChunkContent(event['content'].toString());
            final finalText = parsed['text'] as String;
            if (finalText.isNotEmpty) fullContent = finalText;
          }

        } else if (event['type'] == 'error') {
          throw Exception(event['detail'] ?? 'Lỗi từ server');
        }
      }

      if (!mounted) return;
      if (_messages.isNotEmpty && _messages.last.sender == 'ai') {
        setState(() {
          _messages.last = ChatMessage(
            sender: 'ai',
            text: fullContent.isNotEmpty ? fullContent : _messages.last.text,
            sources: sources,
            hasItinerary: hasItinerary,
            itinerary: itinerary,
            intent: aiIntent,
            confidence: aiConfidence,
            suggestedQuestions: suggested,
            messageId: aiMessageId,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          sender: 'ai',
          text: '❌ ${friendlyError(e)}',
        ));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
    _scrollToBottom();
  }

  // ── [T-035] Feedback like/unlike + báo cáo sai sót ────────────────────────
  Future<void> _sendFeedback(int index, int value,
      {String? reason, String? category}) async {
    if (index < 0 || index >= _messages.length) return;
    final msg = _messages[index];
    if (msg.messageId == null || _isGuest) return;
    // cập nhật UI lạc quan
    setState(() => _messages[index] = ChatMessage(
          sender: msg.sender, text: msg.text, sources: msg.sources,
          intent: msg.intent, confidence: msg.confidence,
          suggestedQuestions: msg.suggestedQuestions,
          hasItinerary: msg.hasItinerary, itinerary: msg.itinerary,
          messageId: msg.messageId, feedback: value,
        ));
    try {
      await _api.updateFeedback(msg.messageId!, value,
          reason: reason, category: category);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.dark,
          content: Text(value == 1
              ? 'Cảm ơn phản hồi của bạn!'
              : 'Đã gửi báo cáo. Cảm ơn bạn đã giúp cải thiện!'),
        ));
      }
    } catch (_) {
      // lỗi mạng → vẫn giữ trạng thái lạc quan, không chặn UX
    }
  }

  // Bottom sheet chọn lý do báo cáo (khi bấm 👎)
  void _openReportSheet(int index) {
    const reasons = {
      'sai_thong_tin': 'Thông tin sai',
      'khong_lien_quan': 'Không liên quan câu hỏi',
      'thieu_nguon': 'Thiếu nguồn / không rõ nguồn',
      'khac': 'Lý do khác',
    };
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Báo cáo câu trả lời',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Vấn đề bạn gặp là gì?',
                  style: TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 12),
              ...reasons.entries.map((e) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.flag_outlined,
                        size: 18, color: AppColors.error),
                    title: Text(e.value, style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _sendFeedback(index, -1, reason: e.key);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Xử lý tin nhắn cho khách — gọi /chat/guest/stream thật ──────────────

  Future<void> _sendGuestMessage(String trimmed) async {
    try {
      await _incrementGuestCount();

      // Gọi endpoint guest không cần auth
      final guestClient = ApiClient();
      final response = await guestClient.postStream(
        '/chat/guest/stream',
        {'content': trimmed},
      );

      if (response.statusCode == 429) {
        final body = await response.stream.bytesToString();
        String detail = 'Bạn đã dùng hết câu hỏi miễn phí hôm nay.';
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map && decoded['detail'] != null) detail = decoded['detail'].toString();
        } catch (_) {}
        if (mounted) {
          setState(() => _messages.add(ChatMessage(sender: 'ai', text: '⚠️ $detail')));
          _showGuestLimitBanner();
        }
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, 'Lỗi kết nối server (${response.statusCode}).');
      }

      String fullContent = '';
      List<SourceRef> sources = [];
      String aiIntent = '';
      double aiConfidence = 0;
      List<String> suggested = [];
      Map<String, dynamic>? itinerary;
      bool hasItinerary = false;

      await for (final event in SseClient.parse(response)) {
        if (!mounted) break;

        if (event['type'] == 'chunk') {
          final raw = event['content'] as String? ?? '';
          final parsed = parseChatChunkContent(raw);
          fullContent += parsed['text'] as String;

          if (parsed['sources'] != null) {
            sources = (parsed['sources'] as List).map((e) => SourceRef.fromDynamic(e)).toList();
          }

          setState(() {
            if (_messages.isNotEmpty && _messages.last.sender == 'ai') {
              _messages.last = ChatMessage(sender: 'ai', text: fullContent, sources: sources);
            } else {
              _messages.add(ChatMessage(sender: 'ai', text: fullContent));
            }
          });
          _scrollToBottom();

        } else if (event['type'] == 'done') {
          final doneSources = (event['sources'] as List<dynamic>?)
              ?.map((e) => SourceRef.fromDynamic(e))
              .toList();
          if (doneSources != null && doneSources.isNotEmpty) sources = doneSources;

          aiIntent = event['intent']?.toString() ?? '';
          aiConfidence = (event['confidence_score'] as num?)?.toDouble() ?? 0;
          suggested = (event['suggested_questions'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();
          if (event['itinerary'] != null) {
            itinerary = Map<String, dynamic>.from(event['itinerary'] as Map);
            hasItinerary = true;
          }

          // Sync local count với server (server là source of truth)
          final serverRemaining = event['remaining'] as int?;
          if (serverRemaining != null) {
            final serverUsed = _kGuestMaxQuestions - serverRemaining;
            if (serverUsed > _guestQuestionCount) {
              _guestQuestionCount = serverUsed;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(_kGuestCountKey, _guestQuestionCount);
            }
          }

        } else if (event['type'] == 'error') {
          throw Exception(event['detail'] ?? 'Lỗi từ server');
        }
      }

      if (mounted && _messages.isNotEmpty && _messages.last.sender == 'ai') {
        setState(() {
          _messages.last = ChatMessage(
            sender: 'ai',
            text: fullContent.isNotEmpty ? fullContent : _messages.last.text,
            sources: sources,
            intent: aiIntent,
            confidence: aiConfidence,
            suggestedQuestions: suggested,
            hasItinerary: hasItinerary,
            itinerary: itinerary,
          );
        });
      }

      // Câu cuối cùng → hiện banner mời đăng nhập
      if (mounted && _guestLimitReached) _showGuestLimitBanner();

    } catch (e) {
      if (mounted) {
        setState(() => _messages.add(ChatMessage(sender: 'ai', text: '❌ ${friendlyError(e)}')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
    _scrollToBottom();
  }

  void _showGuestLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Đã dùng hết lượt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn đã sử dụng hết $_kGuestMaxQuestions câu hỏi miễn phí hôm nay.',
              style: const TextStyle(fontSize: 14, color: AppColors.dark),
            ),
            const SizedBox(height: 10),
            const Text(
              'Đăng nhập để hỏi không giới hạn, lưu lịch sử hội thoại và nhiều tính năng khác!',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Đăng nhập ngay'),
          ),
        ],
      ),
    );
  }

  void _showGuestLimitBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: AppColors.dark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bạn đã dùng hết 3 câu hỏi miễn phí. Đăng nhập để hỏi không giới hạn!',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Đăng nhập',
          textColor: AppColors.primary,
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
          ),
        ),
      ),
    );
  }

  // [P1] Lưu lịch trình AI thành chuyến đi
  bool _savingTrip = false;
  Future<void> _saveTrip(Map<String, dynamic> itinerary) async {
    if (_savingTrip) return;
    final appState = context.read<AppState>();
    if (!appState.isLoggedIn) {
      _showGuestLimitDialog();
      return;
    }
    setState(() => _savingTrip = true);
    try {
      final tripApi = TripApiService(
        tokenProvider: () => appState.token,
        tokenRefresher: () => appState.refreshAccessToken(),
      );
      // Req 2: lịch trình do AI Trip Planner dựng có sẵn `ai_plan` (đầy đủ item
      // theo giờ/chi phí) → lưu qua /trips/ai/confirm; ngược lại dùng cách cũ.
      final aiPlan = itinerary['ai_plan'];
      if (aiPlan is Map) {
        await tripApi.aiConfirm(Map<String, dynamic>.from(aiPlan));
      } else {
        await tripApi.saveItinerary(itinerary);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('✓ Đã lưu chuyến đi! Xem lại trong mục Chuyến đi.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu chuyến đi: ${friendlyError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _savingTrip = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Guest quota banner (chỉ hiện khi là khách)
    Widget? guestBanner;
    if (_isGuest) {
      final remaining = _guestRemaining;
      guestBanner = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        color: remaining == 0 ? AppColors.error.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.07),
        child: Row(
          children: [
            Icon(
              remaining == 0 ? Icons.lock_outline : Icons.info_outline,
              size: 15,
              color: remaining == 0 ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                remaining == 0
                    ? 'Bạn đã dùng hết $_kGuestMaxQuestions câu hỏi miễn phí hôm nay.'
                    : 'Khách được hỏi miễn phí $remaining/$_kGuestMaxQuestions câu hôm nay.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: remaining == 0 ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.dark),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _error = null; _isLoading = true; });
                    _initSession();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (guestBanner != null) guestBanner,
          // FIX: Quick prompts — hiển thị trong 2 dòng với Wrap thay vì 1 dòng ngang bị cắt
          if (_messages.length <= 1)
            _buildQuickPrompts(),

          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text('Bắt đầu hội thoại!',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Hỏi về du lịch, điểm đến, lịch trình...',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Typing indicator
                      if (_isSending && index == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.primary),
                                ),
                                const SizedBox(width: 10),
                                Text('AI đang xử lý...',
                                    style: TextStyle(
                                        color: AppColors.muted, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isUser = msg.sender == 'user';
                      final sources = msg.sources;

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ConstrainedBox(
                          // FIX: dùng ConstrainedBox với maxWidth tương đối screen
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                            // FIX: minWidth để bubble user không quá hẹp
                            minWidth: 60,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                              boxShadow: isUser
                                  ? null
                                  : [
                                      BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 8)
                                    ],
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
                                        Icon(intentIcon(msg.intent),
                                            size: 13,
                                            color: AppColors.secondary),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(intentLabel(msg.intent),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.secondary,
                                                  fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),

                                ChatMarkdown(
                                  text: msg.text,
                                  isUser: isUser,
                                ),

                                if (!isUser && (msg.confidence) > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text('Độ tin cậy',
                                          style: TextStyle(
                                              fontSize: 10.5,
                                              color: AppColors.muted)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: msg.confidence.clamp(0, 1),
                                            minHeight: 5,
                                            backgroundColor: AppColors.border,
                                            valueColor: AlwaysStoppedAnimation(
                                                confidenceColor(msg.confidence)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${(msg.confidence * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: confidenceColor(msg.confidence)),
                                      ),
                                    ],
                                  ),
                                ],

                                if (!isUser && sources.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  // FIX: Wrap tự xuống dòng, không overflow
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: sources
                                        .where((s) => s.displayLabel.isNotEmpty)
                                        .map((source) {
                                      return Tooltip(
                                        message: source.category.isNotEmpty
                                            ? '${source.category} · ${source.source}'
                                            : source.source,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.link,
                                                  size: 11,
                                                  color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              ConstrainedBox(
                                                constraints: const BoxConstraints(maxWidth: 120),
                                                child: Text(source.displayLabel,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors.primary),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                if (msg.hasItinerary && msg.itinerary != null) ...[
                                  const SizedBox(height: 8),
                                  // ai_plan = lịch trình AI Trip Planner thật (có
                                  // ảnh/khách sạn/chi phí) → dùng TripPlanView
                                  // đồng bộ với AiPlannerScreen/TripDetailsScreen.
                                  // Không có ai_plan = câu trả lời RAG mẫu tĩnh
                                  // (itineraries.json) → giữ ItineraryCard cũ.
                                  if (msg.itinerary!['ai_plan'] is Map)
                                    // Dùng .cast (view sống, KHÔNG copy) để nút
                                    // "Đổi" mutate đúng object mà _saveTrip đọc
                                    // (msg.itinerary['ai_plan']) → bản đã đổi được
                                    // giữ khi bấm "Lưu Chuyến Đi". Đổi tại chỗ,
                                    // không gọi lại AI/RAG, không đụng cache.
                                    Builder(builder: (_) {
                                      final aiPlan = (msg.itinerary!['ai_plan'] as Map)
                                          .cast<String, dynamic>();
                                      return TripPlanView(
                                        plan: aiPlan,
                                        onSwapHotel: () => swapHotel(
                                            context, aiPlan, () => setState(() {})),
                                        onSwapItem: (item) => swapItem(
                                            context, aiPlan, item, () => setState(() {})),
                                      );
                                    })
                                  else
                                    ItineraryCard(
                                        itinerary: Map<String, dynamic>.from(
                                            msg.itinerary!)),
                                ],

                                if (msg.hasItinerary) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => TripDetailsScreen(
                                                itinerary: msg.itinerary)),
                                      ),
                                      icon: const Icon(Icons.map, size: 16),
                                      label: const Text('Xem Lịch Trình Chi Tiết',
                                          style: TextStyle(fontSize: 13)),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 10)),
                                    ),
                                  ),
                                  if (!_isGuest && msg.itinerary != null) ...[
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: _savingTrip
                                            ? null
                                            : () => _saveTrip(Map<String, dynamic>.from(
                                                msg.itinerary!)),
                                        icon: _savingTrip
                                            ? const SizedBox(
                                                width: 14, height: 14,
                                                child: CircularProgressIndicator(strokeWidth: 2))
                                            : const Icon(Icons.bookmark_add_outlined, size: 16),
                                        label: Text(_savingTrip ? 'Đang lưu...' : 'Lưu Chuyến Đi',
                                            style: const TextStyle(fontSize: 13)),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(color: AppColors.primary),
                                            padding: const EdgeInsets.symmetric(vertical: 10)),
                                      ),
                                    ),
                                  ],
                                ],

                                // [P0] Câu hỏi gợi ý — chip bấm để hỏi nhanh
                                if (!isUser && msg.suggestedQuestions.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: msg.suggestedQuestions.map((q) {
                                      return GestureDetector(
                                        onTap: _isSending ? null : () => _sendMessage(q),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                                color: AppColors.secondary
                                                    .withValues(alpha: 0.30)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.north_east,
                                                  size: 11,
                                                  color: AppColors.secondary),
                                              const SizedBox(width: 4),
                                              ConstrainedBox(
                                                constraints: const BoxConstraints(
                                                    maxWidth: 220),
                                                child: Text(q,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.secondary,
                                                        fontWeight: FontWeight.w500),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                // [T-035] Đánh giá like/unlike + báo cáo
                                if (!isUser && !_isGuest && msg.messageId != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text('Hữu ích?',
                                          style: TextStyle(
                                              fontSize: 11, color: AppColors.muted)),
                                      const SizedBox(width: 6),
                                      _FeedbackBtn(
                                        icon: Icons.thumb_up_alt_outlined,
                                        iconActive: Icons.thumb_up_alt,
                                        active: msg.feedback == 1,
                                        color: AppColors.secondary,
                                        onTap: () => _sendFeedback(
                                            index, msg.feedback == 1 ? 0 : 1),
                                      ),
                                      const SizedBox(width: 4),
                                      _FeedbackBtn(
                                        icon: Icons.thumb_down_alt_outlined,
                                        iconActive: Icons.thumb_down_alt,
                                        active: msg.feedback == -1,
                                        color: AppColors.error,
                                        onTap: () => _openReportSheet(index),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // FIX: Input bar — thêm maxLines + điều chỉnh padding an toàn
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // Req 3: là tab → không hiện nút back (chuyển tab bằng bottom nav)
      automaticallyImplyLeading: !widget.embedded,
      title: const Text('Trợ Lý AI Du Lịch',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [
        if (_messages.isNotEmpty)
          IconButton(
            tooltip: 'Trò chuyện mới',
            icon: const Icon(Icons.add_comment_outlined, size: 20),
            onPressed: _isSending ? null : _startNewChat,
          ),
      ],
    );
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _sessionId = null;
      _error = null;
    });
  }

  Widget _buildQuickPrompts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quickPrompts.map((p) => GestureDetector(
          onTap: _isSending ? null : () => _sendMessage(p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _isSending
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isSending
                    ? AppColors.border
                    : AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              p,
              style: TextStyle(
                fontSize: 12,
                color: _isSending ? AppColors.muted : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    // Req 3: khi là tab, thanh bottom-nav (cao ~68 + safe-area) nằm đè lên body
    // (parent dùng extendBody). Chừa khoảng trống để ô nhập không bị che.
    final navClearance =
        widget.embedded ? 68.0 + MediaQuery.of(context).padding.bottom : 0.0;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + navClearance),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !widget.embedded,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !_isSending && !_guestLimitReached,
                  // FIX: cho phép multiline, cuộn bên trong
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Hỏi về du lịch, điểm đến...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // FIX: Send button — căn thẳng bottom
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isSending ? AppColors.muted : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                    _isSending ? Icons.hourglass_bottom : Icons.send,
                    color: Colors.white,
                    size: 18),
                onPressed: (_isSending || _guestLimitReached)
                    ? null
                    : () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// [T-035] Nút đánh giá nhỏ (👍 / 👎)
class _FeedbackBtn extends StatelessWidget {
  final IconData icon;
  final IconData iconActive;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FeedbackBtn({
    required this.icon,
    required this.iconActive,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(active ? iconActive : icon,
            size: 16, color: active ? color : AppColors.muted),
      ),
    );
  }
}