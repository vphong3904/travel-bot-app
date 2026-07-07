// lib/screens/profile/settings_screen.dart
//
// SettingsScreen — Màn hình cài đặt
//
// FIX: Sau logout → pushAndRemoveUntil về LoginRegisterScreen
//      (giống profile_screen, vì settings cũng có thể được mở từ profile)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_user.dart';
import '../../providers/app_state.dart';
import '../../providers/favorites_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_api_service.dart';
import '../../services/favorite_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialog_helpers.dart';
import '../auth/login_register_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loggingOut = false;
  bool _clearingFavorites = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.user;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Cài đặt',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── User info card ─────────────────────────────────────────────
            if (appState.isLoggedIn && user != null) ...[
              _UserInfoCard(user: user),
              const SizedBox(height: 24),
            ],

            // ── Thông báo ─────────────────────────────────────────────────
            const _SectionHeader(title: 'THÔNG BÁO'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Bật thông báo',
              trailing: Switch(
                value: appState.notifications,
                activeTrackColor: AppColors.primary,
                activeThumbColor: Colors.white,
                onChanged: (v) => appState.setNotifications(v),
              ),
            ),
            _SettingsTile(
              icon: Icons.mail_outline,
              title: 'Nhận email du lịch',
              subtitle: 'Gợi ý, ưu đãi, và thông báo mới',
            ),
            const SizedBox(height: 24),

            // ── Dữ liệu ───────────────────────────────────────────────────
            const _SectionHeader(title: 'DỮ LIỆU'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.history_outlined,
              title: 'Xóa lịch sử tìm kiếm',
              subtitle: 'Xóa tất cả các tìm kiếm trước đây',
              onTap: () => _confirmAction(
                'Xóa lịch sử?',
                'Hành động này không thể hoàn tác.',
                () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('recent_searches');
                  await prefs.remove('search_history');
                  if (mounted) showInfoSnackBar(context, 'Lịch sử đã xóa');
                },
              ),
            ),
            if (appState.isLoggedIn)
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Xóa tất cả yêu thích',
                subtitle: _clearingFavorites
                    ? 'Đang xóa...'
                    : 'Loại bỏ các địa điểm đã lưu',
                onTap: _clearingFavorites
                    ? null
                    : () => _confirmAction(
                          'Xóa tất cả yêu thích?',
                          'Bạn sẽ mất các địa điểm đã lưu.',
                          () {
                            Navigator.pop(context);
                            _clearAllFavorites(appState);
                          },
                        ),
              ),
            const SizedBox(height: 24),

            // ── Về ứng dụng ───────────────────────────────────────────────
            const _SectionHeader(title: 'VỀ ỨNG DỤNG'),
            const SizedBox(height: 8),
            const _SettingsTile(
              icon: Icons.info_outline,
              title: 'Phiên bản',
              subtitle: 'PDTrip v1.0.0',
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Điều khoản dịch vụ',
              onTap: () => _showDialog('Điều khoản dịch vụ',
                  'Đây là demo của đồ án tốt nghiệp.'),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Chính sách bảo mật',
              onTap: () => _showDialog(
                  'Chính sách bảo mật', 'Chúng tôi bảo vệ dữ liệu người dùng.'),
            ),
            const SizedBox(height: 24),

            // ── Tài khoản / Đăng xuất ─────────────────────────────────────
            if (appState.isLoggedIn) ...[
              const _SectionHeader(title: 'TÀI KHOẢN'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () => _showChangePasswordDialog(appState),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _loggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.error),
                          )
                        : const Icon(Icons.logout,
                            size: 20, color: AppColors.error),
                  ),
                  title: const Text('Đăng xuất',
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  subtitle: Text(
                    appState.user?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  onTap: _loggingOut ? null : _confirmLogout,
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  void _confirmLogout() {
    _confirmAction(
      'Đăng xuất?',
      'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng.',
      () async {
        Navigator.pop(context); // đóng dialog
        await _doLogout();
      },
      confirmLabel: 'Đăng xuất',
    );
  }

  Future<void> _doLogout() async {
    setState(() => _loggingOut = true);
    try {
      // 1. Revoke token trên server + xóa SharedPreferences
      await context.read<AppState>().logout();

      if (!mounted) return;
      // 2. Navigate về màn Login, xóa toàn bộ stack
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginRegisterScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đăng xuất thất bại: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _confirmAction(
    String title,
    String content,
    VoidCallback onConfirm, {
    String confirmLabel = 'Xác nhận',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(AppState appState) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;
    bool submitting = false;
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Đổi mật khẩu'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: oldCtrl,
                    obscureText: obscure,
                    decoration: const InputDecoration(
                        labelText: 'Mật khẩu hiện tại'),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Vui lòng nhập mật khẩu hiện tại'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: obscure,
                    decoration:
                        const InputDecoration(labelText: 'Mật khẩu mới'),
                    validator: AuthValidators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: obscure,
                    decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới'),
                    validator: (v) => v != newCtrl.text
                        ? 'Mật khẩu xác nhận không khớp'
                        : null,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: !obscure,
                    title: const Text('Hiện mật khẩu',
                        style: TextStyle(fontSize: 13)),
                    onChanged: (v) =>
                        setDialogState(() => obscure = !(v ?? false)),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 4),
                    Text(error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        submitting = true;
                        error = null;
                      });
                      try {
                        await AuthApiService.changePassword(
                          appState.token ?? '',
                          oldPassword: oldCtrl.text,
                          newPassword: newCtrl.text,
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          showInfoSnackBar(
                              context, 'Đã đổi mật khẩu thành công');
                        }
                      } catch (e) {
                        setDialogState(() {
                          submitting = false;
                          error = friendlyError(e);
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }

  // [P4] Xóa tất cả yêu thích — gọi API thật cho từng favorite.
  Future<void> _clearAllFavorites(AppState s) async {
    setState(() => _clearingFavorites = true);
    try {
      final api = FavoriteApiService(token: s.token ?? '');
      final favs = await api.listMyFavorites();
      for (final d in favs) {
        await api.remove(d.id);
      }
      if (mounted) {
        context.read<FavoritesProvider>().notifyChanged();
        showInfoSnackBar(context, 'Đã xóa ${favs.length} yêu thích');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi xóa yêu thích: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _clearingFavorites = false);
    }
  }
}

// ─── User Info Card ───────────────────────────────────────────────────────────

class _UserInfoCard extends StatelessWidget {
  final AppUser user;
  const _UserInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(user.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _Initial(name: user.displayName)),
                  )
                : _Initial(name: user.displayName),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(user.email,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                _RoleBadge(role: user.role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (role) {
      case 'admin':
        label = '⚡ Admin';
        break;
      case 'moderator':
        label = '🛡 Moderator';
        break;
      default:
        label = '✈ Thành viên';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.muted,
            letterSpacing: 1.0),
      );
}

// ─── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(title,
            style: titleStyle ??
                const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(fontSize: 12, color: AppColors.muted))
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 20)
                : null),
        onTap: onTap,
      ),
    );
  }
}