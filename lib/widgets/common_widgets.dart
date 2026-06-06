import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppColors {
  static const primary = Color(0xFF0EA5E9);
  static const primaryDark = Color(0xFF0284C7);
  static const accent = Color(0xFFF97316);
  static const dark = Color(0xFF0F172A);
  static const mid = Color(0xFF334155);
  static const muted = Color(0xFF64748B);
  static const bg = Color(0xFFF0F9FF);
  static const card = Colors.white;
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const gradEnd = Color(0xFF6366F1);

  static const primaryGradient = [primary, gradEnd];
  static const accentGradient = [accent, Color(0xFFEF4444)];
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final EdgeInsetsGeometry? padding;

  const GradientCard({super.key, required this.child, this.colors, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
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
        Text(title, style: AppTheme.heading(size: 18)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: AppTheme.body(size: 12, color: AppColors.primary, weight: FontWeight.w700)),
          ),
      ],
    );
  }
}

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final EdgeInsetsGeometry margin;

  const AppSearchBar({
    super.key,
    this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
              style: AppTheme.body(),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const AppBackButton({super.key, this.onTap, this.iconColor, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? const Color(0xFFF1F5F9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap ?? () => Navigator.maybePop(context),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: iconColor ?? AppColors.dark),
        ),
      ),
    );
  }
}

class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppChoiceChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: AppTheme.body(
            size: 13,
            weight: FontWeight.w600,
            color: selected ? AppColors.primaryDark : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outline;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outline = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: AppFonts.body(size: 14, weight: FontWeight.w700, color: AppColors.primary)),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                  Text(label, style: AppFonts.heading(size: 15, weight: FontWeight.w700, color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

class AppInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AppInfoCard({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: AppTheme.label()),
                const SizedBox(height: 4),
                Text(value, style: AppTheme.body(size: 14, weight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
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
      return Icons.info_outline_rounded;
    case 'destination_advice':
      return Icons.explore_outlined;
    case 'itinerary':
      return Icons.route_outlined;
    case 'service_search':
      return Icons.search_rounded;
    default:
      return Icons.chat_bubble_outline_rounded;
  }
}

String kbCategoryLabel(String category) {
  switch (category) {
    case 'weather':
      return 'Thời tiết';
    case 'budget':
      return 'Ngân sách';
    case 'cuisine':
      return 'Ẩm thực';
    case 'tips':
      return 'Mẹo du lịch';
    case 'itinerary':
      return 'Lịch trình';
    case 'transport':
      return 'Di chuyển';
    case 'recommendation':
      return 'Gợi ý';
    default:
      return category;
  }
}
