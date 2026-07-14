// lib/admin/web/screens/city_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

/// Ảnh đại diện + mô tả cấp thành phố. Trong form "Thêm mới", chọn thành phố
/// từ dropdown DB (/admin/cities) — không gõ tay — để lấy đúng tên + city_slug;
/// 1 item/city_slug. Khi Publish, ảnh sẽ được đồng bộ sang bảng destinations
/// để mobile Explore hiển thị ngay.
class CityScreen extends StatelessWidget {
  const CityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'city',
      title: 'Thành phố',
      columns: [
        ContentColumn(label: 'Tên thành phố', fieldKey: 'name', width: 220),
      ],
      formFields: [
        ContentFormField(
            key: 'name',
            label: 'Chọn thành phố (từ DB)',
            required: true,
            fromCities: true),
        ContentFormField(
            key: 'description', label: 'Mô tả ngắn', maxLines: 4),
      ],
    );
  }
}
