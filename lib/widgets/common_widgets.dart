import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFFF97316);
  static const dark = Color(0xFF1E293B);
  static const muted = Color(0xFF64748B);
  static const bg = Color(0xFFF8FAFC);
  static const card = Colors.white;
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientCard({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [AppColors.primary, const Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: AppColors.primary))),
      ],
    );
  }
}

String formatCurrency(int amount) {
  if (amount == 0) return 'Miễn phí';
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${buf.toString()}đ';
}

String intentLabel(String intent) {
  switch (intent) {
    case 'faq_info':
      return 'Hỏi thông tin';
    case 'destination_advice':
      return 'Tư vấn điểm đến';
    case 'itinerary':
      return 'Lập lịch trình';
    case 'service_search':
      return 'Tìm dịch vụ';
    default:
      return intent;
  }
}

IconData intentIcon(String intent) {
  switch (intent) {
    case 'faq_info':
      return Icons.info_outline;
    case 'destination_advice':
      return Icons.explore;
    case 'itinerary':
      return Icons.route;
    case 'service_search':
      return Icons.search;
    default:
      return Icons.chat;
  }
}
