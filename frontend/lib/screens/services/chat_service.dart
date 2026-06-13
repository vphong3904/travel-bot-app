// lib/services/chat_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// ChatService — kết nối WebSocket tới backend, gửi/nhận tin nhắn thật.
//
// Cách dùng trong widget:
//   final _chat = ChatService(userId: currentUser.id, userName: currentUser.name);
//   await _chat.connect();
//   _chat.messages.listen((msg) { setState(() { _messages.add(msg); }); });
//   await _chat.send("Tôi muốn đi Đà Lạt 3 ngày");
//   await _chat.disconnect();
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Một tin nhắn đã được parse từ backend hoặc tạo ra cục bộ.
class ChatMessage {
  final String sender; // 'user' | 'ai' | 'system'
  final String text;
  final bool hasItinerary;
  final Map<String, dynamic>? itinerary;
  final List<dynamic>? destinations;
  final List<dynamic>? services;
  final List<String> sources;
  final String intent;
  final double confidence;
  final bool isTyping; // true = placeholder spinner

  const ChatMessage({
    required this.sender,
    required this.text,
    this.hasItinerary = false,
    this.itinerary,
    this.destinations,
    this.services,
    this.sources = const [],
    this.intent = '',
    this.confidence = 0,
    this.isTyping = false,
  });

static const String _baseUrl = 'ws://10.0.2.2:8000';

  /// Tin nhắn "đang gõ..." (hiển thị spinner trong khi chờ backend)
  factory ChatMessage.typing() => const ChatMessage(
        sender: 'ai',
        text: '',
        isTyping: true,
      );

  /// Tin nhắn lỗi hiển thị trong bubble AI
  factory ChatMessage.error(String message) => ChatMessage(
        sender: 'ai',
        text: message,
        intent: 'error',
      );

  /// Parse từ JSON trả về bởi backend WebSocket
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: 'ai',
        text: json['text'] as String? ?? '',
        hasItinerary: json['has_itinerary'] as bool? ?? false,
        itinerary: json['itinerary'] as Map<String, dynamic>?,
        destinations: json['destinations'] as List<dynamic>?,
        services: json['services'] as List<dynamic>?,
        sources: (json['sources'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        intent: json['intent'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      );

  ChatMessage copyWith({String? text, bool? isTyping}) => ChatMessage(
        sender: sender,
        text: text ?? this.text,
        hasItinerary: hasItinerary,
        itinerary: itinerary,
        destinations: destinations,
        services: services,
        sources: sources,
        intent: intent,
        confidence: confidence,
        isTyping: isTyping ?? this.isTyping,
      );
}

/// Trạng thái kết nối WebSocket
enum ChatConnectionState { disconnected, connecting, connected, reconnecting }

/// ChatService — lớp duy nhất giao tiếp với backend.
///
/// • Tự động reconnect với back-off exponential (tối đa [maxRetries] lần).
/// • Expose [messages] stream để widget lắng nghe.
/// • Expose [connectionState] stream để hiển thị trạng thái kết nối.
class ChatService {
  // ── Cấu hình ──────────────────────────────────────────────────────────────

  /// Base URL của backend, ví dụ: "http://192.168.1.10:8000"
  /// WS URL sẽ là "ws://192.168.1.10:8000/api/chat/ws/<userId>"
  static const String _baseUrl = 'ws://10.0.2.2:8000'; // Android emulator
  // static const String _baseUrl = 'ws://localhost:8000'; // iOS simulator / web
  // static const String _baseUrl = 'ws://192.168.x.x:8000'; // thiết bị thật

  static const int maxRetries = 5;
  static const Duration _pingInterval = Duration(seconds: 25);

  // ── State ──────────────────────────────────────────────────────────────────

  final int userId;
  final String userName;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  int _retryCount = 0;
  bool _manualDisconnect = false;

  // ── Streams ────────────────────────────────────────────────────────────────

  final _messageController = StreamController<ChatMessage>.broadcast();
  final _stateController =
      StreamController<ChatConnectionState>.broadcast();
  final _typingController = StreamController<bool>.broadcast();

  /// Stream nhận ChatMessage mới (cả user và AI).
  Stream<ChatMessage> get messages => _messageController.stream;

  /// Stream trạng thái kết nối WS.
  Stream<ChatConnectionState> get connectionState => _stateController.stream;

  /// Stream typing indicator (true = AI đang xử lý).
  Stream<bool> get typingStream => _typingController.stream;

  ChatService({required this.userId, this.userName = 'Khách'});

  // ── Connect / Disconnect ───────────────────────────────────────────────────

  Future<void> connect() async {
    if (_channel != null) return; // đã kết nối
    _manualDisconnect = false;
    _retryCount = 0;
    await _doConnect();
  }

  Future<void> _doConnect() async {
    _stateController.add(ChatConnectionState.connecting);

    final uri = Uri.parse('$_baseUrl/api/chat/ws/$userId');

    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready; // throws nếu handshake thất bại

      _stateController.add(ChatConnectionState.connected);
      _retryCount = 0;

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _startPing();
    } catch (e) {
      _stateController.add(ChatConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _cancelTimers();
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    _stateController.add(ChatConnectionState.disconnected);
  }

  // ── Gửi tin nhắn ──────────────────────────────────────────────────────────

  /// Gửi tin nhắn văn bản lên backend.
  /// Trả về false nếu chưa kết nối.
  bool send(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return false;
    if (_channel == null) return false;

    // Thêm tin nhắn user vào stream ngay lập tức (optimistic UI)
    _messageController.add(ChatMessage(sender: 'user', text: trimmed));

    // Gửi lên server
    _channel!.sink.add(jsonEncode({
      'message': trimmed,
      'user_name': userName,
      'user_id': userId,
    }));

    return true;
  }

  // ── Xử lý dữ liệu nhận về ─────────────────────────────────────────────────

  void _onMessage(dynamic raw) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return; // bỏ qua payload không phải JSON
    }

    final type = json['type'] as String? ?? 'response';

    switch (type) {
      case 'typing':
        // Backend báo đang xử lý → hiển thị spinner
        _typingController.add(true);
        break;

      case 'response':
        _typingController.add(false);
        _messageController.add(ChatMessage.fromJson(json));
        break;

      case 'error':
        _typingController.add(false);
        _messageController.add(ChatMessage.error(
          json['text'] as String? ?? '⚠️ Lỗi không xác định từ server.',
        ));
        break;

      default:
        // Bỏ qua các type khác (ping/pong, admin push, ...)
        break;
    }
  }

  void _onError(Object error) {
    _typingController.add(false);
    _scheduleReconnect();
  }

  void _onDone() {
    if (_manualDisconnect) return;
    _channel = null;
    _sub = null;
    _scheduleReconnect();
  }

  // ── Ping giữ kết nối ──────────────────────────────────────────────────────

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (_) {}
    });
  }

  // ── Auto-reconnect với exponential back-off ────────────────────────────────

  void _scheduleReconnect() {
    if (_manualDisconnect) return;
    if (_retryCount >= maxRetries) {
      _stateController.add(ChatConnectionState.disconnected);
      _messageController.add(
        ChatMessage.error(
          '❌ Mất kết nối với server. Vui lòng kiểm tra mạng và thử lại.',
        ),
      );
      return;
    }

    _retryCount++;
    final delay = Duration(seconds: _retryCount * 2); // 2s, 4s, 6s, 8s, 10s
    _stateController.add(ChatConnectionState.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      _channel = null;
      await _sub?.cancel();
      _sub = null;
      await _doConnect();
    });
  }

  void _cancelTimers() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _pingTimer = null;
    _reconnectTimer = null;
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _stateController.close();
    await _typingController.close();
  }
}