// lib/admin/web/screens/hotels_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'hotels',
      title: 'Khách sạn',
      columns: [
        ContentColumn(
            label: 'Tên khách sạn', fieldKey: 'name', width: 200),
        ContentColumn(
            label: 'Hạng sao', fieldKey: 'stars', width: 80),
        ContentColumn(
            label: 'Địa chỉ', fieldKey: 'address', width: 180),
        ContentColumn(
            label: 'Giá từ', fieldKey: 'price_from', width: 100),
      ],
      formFields: [
        ContentFormField(
            key: 'name', label: 'Tên khách sạn', required: true),
        ContentFormField(
          key: 'stars',
          label: 'Hạng sao',
          options: ['1', '2', '3', '4', '5'],
        ),
        ContentFormField(key: 'address', label: 'Địa chỉ'),
        ContentFormField(
            key: 'price_from', label: 'Giá từ (VNĐ/đêm)'),
        ContentFormField(
            key: 'description', label: 'Mô tả', maxLines: 4),
        ContentFormField(
          key: 'amenities',
          label: 'Tiện nghi (cách nhau bởi dấu phẩy)',
        ),
        ContentFormField(
            key: 'phone', label: 'Số điện thoại'),
        ContentFormField(key: 'website', label: 'Website'),
      ],
    );
  }
}
