// lib/admin/web/widgets/content_status_badge.dart
import 'package:flutter/material.dart';

class ContentStatusBadge extends StatelessWidget {
  final String status;
  const ContentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDraft = status == 'draft';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDraft ? Colors.grey.shade100 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDraft ? Colors.grey.shade300 : Colors.green.shade200,
        ),
      ),
      child: Text(
        isDraft ? 'Draft' : 'Published',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDraft
              ? Colors.grey.shade700
              : Colors.green.shade700,
        ),
      ),
    );
  }
}
