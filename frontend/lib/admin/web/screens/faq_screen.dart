// lib/admin/web/screens/faq_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'faq',
      title: 'FAQ',
      columns: [
        ContentColumn(
            label: 'Câu hỏi', fieldKey: 'question', width: 300),
        ContentColumn(
          label: 'Category',
          fieldKey: 'category',
          width: 120,
        ),
      ],
      formFields: [
        ContentFormField(
          key: 'question',
          label: 'Câu hỏi',
          required: true,
          maxLines: 2,
        ),
        ContentFormField(
          key: 'answer',
          label: 'Câu trả lời',
          required: true,
          maxLines: 5,
        ),
        ContentFormField(
          key: 'category',
          label: 'Category',
          options: ['Visa', 'Tiền tệ', 'An toàn', 'Đặt phòng', 'Di chuyển', 'Khác'],
        ),
      ],
    );
  }
}
