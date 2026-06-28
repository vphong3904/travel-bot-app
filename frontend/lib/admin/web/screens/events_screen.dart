// lib/admin/web/screens/events_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'events',
      title: 'Sự kiện',
      columns: [
        ContentColumn(
            label: 'Tên sự kiện', fieldKey: 'name', width: 200),
        ContentColumn(
            label: 'Ngày', fieldKey: 'date', width: 100),
        ContentColumn(
            label: 'Địa điểm', fieldKey: 'venue', width: 160),
        ContentColumn(
            label: 'Loại', fieldKey: 'type', width: 100),
      ],
      formFields: [
        ContentFormField(
            key: 'name', label: 'Tên sự kiện', required: true),
        ContentFormField(key: 'date', label: 'Ngày tổ chức'),
        ContentFormField(key: 'venue', label: 'Địa điểm'),
        ContentFormField(
          key: 'type',
          label: 'Loại',
          options: ['Lễ hội', 'Văn hóa', 'Thể thao', 'Âm nhạc', 'Ẩm thực'],
        ),
        ContentFormField(
            key: 'description', label: 'Mô tả', maxLines: 4),
      ],
    );
  }
}
