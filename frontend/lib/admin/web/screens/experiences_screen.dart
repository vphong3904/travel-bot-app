// lib/admin/web/screens/experiences_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class ExperiencesScreen extends StatelessWidget {
  const ExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'experiences',
      title: 'Trải nghiệm',
      columns: [
        ContentColumn(
            label: 'Tiêu đề', fieldKey: 'title', width: 220),
        ContentColumn(
            label: 'Mô tả ngắn', fieldKey: 'summary', width: 280),
      ],
      formFields: [
        ContentFormField(
            key: 'title', label: 'Tiêu đề', required: true),
        ContentFormField(
            key: 'summary', label: 'Mô tả ngắn'),
        ContentFormField(
          key: 'content',
          label: 'Nội dung chi tiết',
          required: true,
          maxLines: 8,
        ),
      ],
    );
  }
}
