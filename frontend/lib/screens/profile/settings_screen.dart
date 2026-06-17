import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialog_helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'vi';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section: Hiển thị
            _SectionHeader(title: 'HIỂN THỊ'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Chế độ tối',
              trailing: Switch(
                value: _darkModeEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  // Tính năng placeholder
                },
              ),
            ),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'Ngôn ngữ',
              subtitle: _selectedLanguage == 'vi' ? 'Tiếng Việt' : 'English',
              onTap: _showLanguageDialog,
            ),
            const SizedBox(height: 24),

            // Section: Thông báo
            _SectionHeader(title: 'THÔNG BÁO'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Bật thông báo',
              trailing: Switch(
                value: _notificationsEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  // Tính năng placeholder
                },
              ),
            ),
            _SettingsTile(
              icon: Icons.mail_outline,
              title: 'Nhận email du lịch',
              subtitle: 'Gợi ý, ưu đãi, và thông báo mới',
            ),
            const SizedBox(height: 24),

            // Section: Dữ liệu
            _SectionHeader(title: 'DỮ LIỆU'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.history_outlined,
              title: 'Xóa lịch sử tìm kiếm',
              subtitle: 'Xóa tất cả các tìm kiếm trước đây',
              onTap: () => _showConfirmDialog(
                'Xóa lịch sử?',
                'Hành động này không thể hoàn tác.',
                () {
                  // Tính năng placeholder
                  Navigator.pop(context);
                  showInfoSnackBar(context, 'Lịch sử đã xóa');
                },
              ),
            ),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Xóa tất cả yêu thích',
              subtitle: 'Loại bỏ các địa điểm đã lưu',
              onTap: () => _showConfirmDialog(
                'Xóa tất cả yêu thích?',
                'Bạn sẽ mất các địa điểm đã lưu.',
                () {
                  Navigator.pop(context);
                  showInfoSnackBar(context, 'Yêu thích đã xóa');
                },
              ),
            ),
            const SizedBox(height: 24),

            // Section: Về ứng dụng
            _SectionHeader(title: 'VỀ ỨNG DỤNG'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'Phiên bản',
              subtitle: 'AI Travel Advisor v1.0.0',
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Điều khoản dịch vụ',
              onTap: () {
                _showDialog('Điều khoản dịch vụ', 'Đây là demo của đồ án tốt nghiệp.');
              },
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Chính sách bảo mật',
              onTap: () {
                _showDialog('Chính sách bảo mật', 'Chúng tôi bảo vệ dữ liệu người dùng.');
              },
            ),
            const SizedBox(height: 24),

            // Section: Tài khoản
            if (appState.isLoggedIn) ...[
              _SectionHeader(title: 'TÀI KHOẢN'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Đăng xuất',
                titleStyle: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                onTap: () => _showConfirmDialog(
                  'Đăng xuất?',
                  'Bạn sẽ cần đăng nhập lại để tiếp tục.',
                  () async {
                    await appState.logout();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'vi',
              title: const Text('Tiếng Việt'),
              selected: _selectedLanguage == 'vi',
              onChanged: (value) {
                setState(() => _selectedLanguage = value ?? 'vi');
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: 'en',
              title: const Text('English'),
              selected: _selectedLanguage == 'en',
              onChanged: (value) {
                setState(() => _selectedLanguage = value ?? 'en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.muted,
        letterSpacing: 0.8,
      ),
    );
  }
}

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(title, style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(fontSize: 12, color: AppColors.muted)) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
