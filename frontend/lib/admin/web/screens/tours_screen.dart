// lib/admin/web/screens/tours_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'tours',
      title: 'Tour du lịch',
      columns: [
        ContentColumn(
            label: 'Tên tour', fieldKey: 'name', width: 200),
        ContentColumn(
            label: 'Loại', fieldKey: 'type', width: 100),
        ContentColumn(
            label: 'Giá', fieldKey: 'price', width: 100),
        ContentColumn(
            label: 'Thời gian',
            fieldKey: 'duration',
            width: 100),
      ],
      formFields: [
        ContentFormField(
            key: 'name', label: 'Tên tour', required: true),
        ContentFormField(
          key: 'type',
          label: 'Loại',
          options: ['Solo', 'Couple', 'Family', 'Group'],
        ),
        ContentFormField(key: 'price', label: 'Giá (VNĐ)'),
        ContentFormField(
          key: 'duration',
          label: 'Thời gian (vd: 2 ngày 1 đêm)',
        ),
        ContentFormField(
            key: 'description', label: 'Mô tả', maxLines: 4),
        ContentFormField(
            key: 'includes', label: 'Bao gồm', maxLines: 3),
      ],
    );
  }
}
