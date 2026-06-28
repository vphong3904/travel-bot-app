// lib/admin/web/widgets/role_badge.dart
import 'package:flutter/material.dart';

const _roleConfig = {
  'super_admin': (
    label: 'Super Admin',
    color: Color(0xFF7C3AED),
    bg: Color(0xFFF3E8FF),
  ),
  'admin': (
    label: 'Admin',
    color: Color(0xFFDC2626),
    bg: Color(0xFFFEE2E2),
  ),
  'content_manager': (
    label: 'Content Mgr',
    color: Color(0xFFD97706),
    bg: Color(0xFFFEF3C7),
  ),
  'moderator': (
    label: 'Moderator',
    color: Color(0xFF2563EB),
    bg: Color(0xFFDBEAFE),
  ),
  'user': (
    label: 'User',
    color: Color(0xFF6B7280),
    bg: Color(0xFFF3F4F6),
  ),
};

class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final cfg = _roleConfig[role] ??
        (label: role, color: const Color(0xFF6B7280), bg: const Color(0xFFF3F4F6));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        cfg.label,
        style: TextStyle(
          color: cfg.color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
