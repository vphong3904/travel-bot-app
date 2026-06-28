// lib/admin/web/screens/restaurants_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'restaurants',
      title: 'Nhà hàng',
      columns: [
        ContentColumn(
            label: 'Tên', fieldKey: 'name', width: 200),
        ContentColumn(
            label: 'Địa chỉ', fieldKey: 'address', width: 180),
        ContentColumn(
            label: 'Giờ mở', fieldKey: 'open_hours', width: 120),
        ContentColumn(
          label: 'Loại ẩm thực',
          fieldKey: 'cuisine_type',
          width: 120,
        ),
      ],
      formFields: [
        ContentFormField(
            key: 'name', label: 'Tên nhà hàng', required: true),
        ContentFormField(key: 'address', label: 'Địa chỉ'),
        ContentFormField(
            key: 'open_hours', label: 'Giờ mở cửa'),
        ContentFormField(
          key: 'cuisine_type',
          label: 'Loại ẩm thực',
          options: ['Việt Nam', 'Hải sản', 'Âu', 'Châu Á', 'Thuần chay'],
        ),
        ContentFormField(
          key: 'price_range',
          label: 'Mức giá',
          options: ['Bình dân', 'Trung cấp', 'Cao cấp'],
        ),
      ],
    );
  }
}
