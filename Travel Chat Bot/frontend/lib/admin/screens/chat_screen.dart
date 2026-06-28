import 'package:flutter/material.dart';
import '../widgets/placeholder_page.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderPage(title: 'Quản lý hội thoại', taskRef: 'TA-007');
}
