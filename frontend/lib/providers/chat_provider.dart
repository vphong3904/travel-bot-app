import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isConnected = false;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isConnected => _isConnected;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void setTyping(bool value) {
    _isTyping = value;
    notifyListeners();
  }

  void setConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void removeLastMessage() {
    if (_messages.isNotEmpty) {
      _messages.removeLast();
      notifyListeners();
    }
  }
}
