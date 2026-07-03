// lib/admin/web/screens/shopping_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'shopping',
      title: 'Mua sắm',
      columns: [
        ContentColumn(
            label: 'Tên địa điểm', fieldKey: 'name', width: 200),
        ContentColumn(
          label: 'Loại hàng',
          fieldKey: 'goods_type',
          width: 120,
        ),
        ContentColumn(
            label: 'Khu vực', fieldKey: 'area', width: 150),
      ],
      formFields: [
        ContentFormField(
            key: 'name',
            label: 'Tên địa điểm',
            required: true),
        ContentFormField(
          key: 'goods_type',
          label: 'Loại hàng',
          options: ['market', 'mall', 'specialty_store', 'street', 'other'],
        ),
        ContentFormField(key: 'area', label: 'Khu vực'),
        ContentFormField(
            key: 'description', label: 'Mô tả', maxLines: 3),
      ],
    );
  }
}
