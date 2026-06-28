// lib/admin/web/screens/itineraries_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class ItinerariesScreen extends StatelessWidget {
  const ItinerariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'itineraries',
      title: 'Lịch trình',
      columns: [
        ContentColumn(
            label: 'Tiêu đề', fieldKey: 'title', width: 220),
        ContentColumn(
            label: 'Số ngày', fieldKey: 'days', width: 80),
        ContentColumn(
            label: 'Loại', fieldKey: 'type', width: 100),
      ],
      formFields: [
        ContentFormField(
            key: 'title', label: 'Tiêu đề', required: true),
        ContentFormField(key: 'days', label: 'Số ngày'),
        ContentFormField(
          key: 'type',
          label: 'Loại',
          options: ['Gia đình', 'Cặp đôi', 'Bạn bè', 'Solo', 'Tiết kiệm'],
        ),
        ContentFormField(
            key: 'description',
            label: 'Mô tả chi tiết',
            maxLines: 6),
      ],
    );
  }
}
