import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_register_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/chat_logs_screen.dart';
import '../chat/chatbot_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.user;
    final initial = (user?.name ?? 'K').substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                    ),
                    child: Center(child: Text(initial, style: AppTheme.heading(size: 36, color: Colors.white))),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'Khách (Demo)', style: AppTheme.heading(size: 22, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'Chưa đăng nhập', style: AppTheme.body(size: 14, color: Colors.white.withValues(alpha: 0.8))),
                  if (user?.isAdmin == true) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('Quản Trị Viên', style: AppTheme.body(size: 12, color: Colors.white, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatCard(num: user?.isAdmin == true ? '12' : '3', label: 'Chuyến đi'),
                    const SizedBox(width: 12),
                    _StatCard(num: user?.isAdmin == true ? '48' : '8', label: 'Tin nhắn'),
                    const SizedBox(width: 12),
                    _StatCard(num: user?.isAdmin == true ? '5' : '2', label: 'Điểm đến'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat với AI',
                    subtitle: 'Hỏi đáp du lịch thông minh',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotScreen())),
                  ),
                  if (user?.isAdmin == true)
                    _MenuItem(
                      icon: Icons.history_rounded,
                      title: 'Lịch sử hội thoại',
                      subtitle: 'Xem log chatbot hệ thống',
                      iconBg: const Color(0xFFFFF7ED),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatLogsScreen())),
                    ),
                  if (user?.isAdmin == true)
                    _MenuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Quản trị hệ thống',
                      subtitle: 'KB, Users, Thống kê',
                      iconBg: const Color(0xFFFFF7ED),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
                    ),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Về ứng dụng',
                    subtitle: 'AI Travel Advisor v2.0',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AI Travel Advisor',
                        applicationVersion: '2.0.0',
                        children: const [
                          Text('Chatbot tư vấn du lịch với NLP, Intent Recognition và RAG.\n\nBackend: FastAPI\nFrontend: Flutter\nVector DB: FAISS'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (appState.isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await appState.logout();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                        label: Text('Đăng xuất an toàn', style: AppTheme.heading(size: 15, color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: const Color(0xFFFEF2F2),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    )
                  else
                    AppPrimaryButton(
                      label: 'Đăng nhập',
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String num;
  final String label;

  const _StatCard({required this.num, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Text(num, style: AppTheme.heading(size: 24, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: AppTheme.label()),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBg;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBg = const Color(0xFFF0F9FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF8FAFC)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppTheme.body(size: 15, weight: FontWeight.w700)),
        subtitle: Text(subtitle, style: AppTheme.body(size: 12, color: AppColors.muted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
      ),
    );
  }
}
