import 'package:flutter/material.dart';
import '../widgets/placeholder_page.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderPage(title: 'Quản lý nội dung', taskRef: 'TA-015');
}
