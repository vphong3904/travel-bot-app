// lib/admin/web/screens/foods_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class FoodsScreen extends StatelessWidget {
  const FoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'foods',
      title: 'Ẩm thực đặc sản',
      columns: [
        ContentColumn(
            label: 'Tên món', fieldKey: 'name', width: 200),
        ContentColumn(
          label: 'Loại',
          fieldKey: 'type',
          width: 120,
        ),
        ContentColumn(
            label: 'Mô tả', fieldKey: 'description', width: 250),
      ],
      formFields: [
        ContentFormField(
            key: 'name', label: 'Tên món', required: true),
        ContentFormField(
          key: 'type',
          label: 'Loại',
          options: [
            'main_dish', 'specialty', 'snack', 'dessert', 'seafood', 'noodle',
            'soup', 'beef', 'fruit', 'drink', 'beverage', 'condiment', 'market',
          ],
        ),
        ContentFormField(
            key: 'description', label: 'Mô tả', maxLines: 3),
        ContentFormField(key: 'origin', label: 'Nguồn gốc'),
        ContentFormField(
            key: 'how_to_eat', label: 'Cách thưởng thức'),
      ],
    );
  }
}
