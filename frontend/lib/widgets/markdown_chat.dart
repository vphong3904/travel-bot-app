import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/common_widgets.dart';
String cleanMessage(String text) {
  return text
        .replaceAll(
          RegExp(r'<<<SUGGESTED[\s\S]*'),
          '',
        )
        .trim();
}

class ChatMarkdown extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMarkdown({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: cleanMessage(text),
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: isUser ? Colors.white : AppColors.dark,
          height: 1.5,
        ),
        strong: TextStyle(
          color: isUser ? Colors.white : AppColors.dark,
          fontWeight: FontWeight.bold,
        ),
        listBullet: TextStyle(
          color: isUser ? Colors.white : AppColors.dark,
        ),
      ),
    );
  }
}