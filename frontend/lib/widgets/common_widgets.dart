import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  APP COLORS
// ─────────────────────────────────────────────
class AppColors {
  static const primary   = Color(0xFF2563EB);
  static const secondary = Color(0xFFF97316);
  static const dark      = Color(0xFF1E293B);
  static const muted     = Color(0xFF64748B);
  static const bg        = Color(0xFFF8FAFC);
  static const card      = Colors.white;
  static const success   = Color(0xFF10B981);
  static const error     = Color(0xFFEF4444);

  static const Color accent    = Color(0xFF38C9A8);
  static const Color gradStart = Color(0xFF4F7FFA);
  static const Color gradEnd   = Color(0xFF8B5CF6);
  static const Color mid       = Color(0xFF475569);
  static const Color border    = Color(0xFFF1F5F9);
  static const Color surface   = Color(0xFFF8FAFC);
  static const Color white     = Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradStart, gradEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF6EE7B7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────────
//  GRADIENT CARD
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
//  SECTION TITLE
// ─────────────────────────────────────────────
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(color: AppColors.primary)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  KB CATEGORY LABEL
// ─────────────────────────────────────────────
String kbCategoryLabel(String category) {
  switch (category) {
    case 'weather':        return 'Thời tiết';
    case 'budget':         return 'Ngân sách';
    case 'cuisine':        return 'Ẩm thực';
    case 'tips':           return 'Mẹo du lịch';
    case 'itinerary':      return 'Lịch trình';
    case 'transport':      return 'Di chuyển';
    case 'recommendation': return 'Gợi ý';
    default:               return category;
  }
}

// ─────────────────────────────────────────────
//  INTENT LABEL & ICON
// ─────────────────────────────────────────────
String intentLabel(String intent) {
  switch (intent) {
    case 'faq_info':          return 'Hỏi thông tin';
    case 'destination_advice': return 'Tư vấn điểm đến';
    case 'itinerary':          return 'Lập lịch trình';
    case 'service_search':     return 'Tìm dịch vụ';
    default:                   return intent;
  }
}

IconData intentIcon(String intent) {
  switch (intent) {
    case 'faq_info':          return Icons.info_outline;
    case 'destination_advice': return Icons.explore;
    case 'itinerary':          return Icons.route;
    case 'service_search':     return Icons.search;
    default:                   return Icons.chat;
  }
}

// ─────────────────────────────────────────────
//  FORMAT CURRENCY
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
//  PRIMARY BUTTON
// ─────────────────────────────────────────────
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SEARCH BAR
// ─────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? margin;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Tìm kiếm...',
    this.onChanged,
    this.onClear,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.muted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                      onClear?.call();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}