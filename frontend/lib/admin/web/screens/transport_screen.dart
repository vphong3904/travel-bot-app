// lib/admin/web/screens/transport_screen.dart
import 'package:flutter/material.dart';
import '../widgets/content_form_sheet.dart';
import 'content_screen.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentScreen(
      contentType: 'transport',
      title: 'Di chuyển',
      columns: [
        ContentColumn(
            label: 'Phương tiện',
            fieldKey: 'vehicle',
            width: 140),
        ContentColumn(
            label: 'Tuyến', fieldKey: 'route', width: 200),
        ContentColumn(
          label: 'Giá ước tính',
          fieldKey: 'estimated_price',
          width: 120,
        ),
      ],
      formFields: [
        ContentFormField(
            key: 'vehicle',
            label: 'Phương tiện',
            required: true),
        ContentFormField(key: 'route', label: 'Tuyến đường'),
        ContentFormField(
            key: 'estimated_price', label: 'Giá ước tính'),
        ContentFormField(
            key: 'notes', label: 'Ghi chú', maxLines: 3),
      ],
    );
  }
}
