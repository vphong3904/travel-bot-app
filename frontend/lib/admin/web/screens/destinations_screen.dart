// lib/admin/web/screens/destinations_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class DestinationsScreen extends StatelessWidget {
  const DestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'destinations',
      title: 'Địa điểm du lịch',
      columns: [
        ContentColumn(
            label: 'Tên địa điểm', fieldKey: 'name', width: 200),
        ContentColumn(
            label: 'Loại', fieldKey: 'type', width: 100),
        ContentColumn(
            label: 'Địa chỉ', fieldKey: 'address', width: 200),
        ContentColumn(
            label: 'Đánh giá', fieldKey: 'rating', width: 80),
      ],
      formFields: [
        ContentFormField(
            key: 'name', label: 'Tên địa điểm', required: true),
        ContentFormField(
          key: 'type',
          label: 'Loại',
          options: ['Di tích', 'Thiên nhiên', 'Vui chơi', 'Văn hóa'],
        ),
        ContentFormField(key: 'address', label: 'Địa chỉ'),
        ContentFormField(
            key: 'description', label: 'Mô tả', maxLines: 5),
        ContentFormField(key: 'rating', label: 'Đánh giá (1-5)'),
        ContentFormField(
            key: 'open_hours', label: 'Giờ mở cửa'),
        ContentFormField(
            key: 'entrance_fee', label: 'Vé vào cửa'),
        ContentFormField(
            key: 'tips', label: 'Tips du lịch', maxLines: 3),
      ],
    );
  }
}
