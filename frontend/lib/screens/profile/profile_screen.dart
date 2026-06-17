import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../admin/admin_dashboard_screen.dart';
import '../chat/chatbot_screen.dart';
import '../chat/chat_history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.user;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  (user?.displayName ?? 'K').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.displayName ?? 'Khách (Demo)', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(user?.email ?? 'Chưa đăng nhập', style: TextStyle(color: AppColors.muted, fontSize: 13)),
              if (user?.isAdmin == true)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Admin', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              const SizedBox(height: 24),
              
              // Thống kê nhanh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(label: 'Chuyến đi', value: '5'),
                  Container(width: 1, height: 30, color: Colors.grey.withValues(alpha: 0.3)),
                  _StatItem(label: 'Câu hỏi AI', value: '128'),
                  Container(width: 1, height: 30, color: Colors.grey.withValues(alpha: 0.3)),
                  _StatItem(label: 'Yêu thích', value: '12'),
                ],
              ),
              const SizedBox(height: 32),

              _SectionHeader(title: 'Hoạt động của tôi'),
              _MenuTile(icon: Icons.smart_toy, title: 'Chat với AI', subtitle: 'Hỏi đáp du lịch thông minh', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotScreen()));
              }),
              _MenuTile(icon: Icons.history, title: 'Lịch sử hội thoại', subtitle: 'Xem lại các cuộc trò chuyện', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen()));
              }),
              _MenuTile(icon: Icons.favorite_border, title: 'Địa điểm đã lưu', subtitle: 'Danh sách khách sạn & điểm đến'),

              const SizedBox(height: 16),
              _SectionHeader(title: 'Hệ thống'),
              if (user?.isAdmin == true)
                _MenuTile(icon: Icons.admin_panel_settings, title: 'Quản trị hệ thống', subtitle: 'KB, Users, Stats', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                }),
              _MenuTile(icon: Icons.settings_outlined, title: 'Cài đặt', subtitle: 'Ngôn ngữ, thông báo, giao diện', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
              _MenuTile(icon: Icons.info_outline, title: 'Về ứng dụng', subtitle: 'AI Travel Advisor v1.0 - RAG Demo', onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'AI Travel Advisor',
                  applicationVersion: '1.0.0',
                  children: const [Text('Chatbot tư vấn du lịch với NLP, Intent Recognition và RAG.\n\nBackend: FastAPI\nFrontend: Flutter\nVector DB: FAISS')],
                );
              }),
              _MenuTile(icon: Icons.help_outline, title: 'Hỗ trợ & Góp ý', subtitle: 'Liên hệ với chúng tôi'),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1.1),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.muted)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
