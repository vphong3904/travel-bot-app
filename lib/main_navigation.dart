import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'widgets/common_widgets.dart';
import 'theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    (icon: Icons.explore_outlined, active: Icons.explore_rounded, label: 'Khám phá'),
    (icon: Icons.chat_bubble_outline_rounded, active: Icons.chat_bubble_rounded, label: 'AI Chat'),
    (icon: Icons.hotel_outlined, active: Icons.hotel_rounded, label: 'Dịch vụ'),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded, label: 'Hồ sơ'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    const screens = [
      ExploreScreen(),
      ChatBotScreen(),
      ServicesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: user?.isAdmin == true
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
              backgroundColor: AppColors.dark,
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: Text('Admin', style: AppTheme.body(size: 13, color: Colors.white, weight: FontWeight.w700)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = _currentIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(active ? tab.active : tab.icon, size: 22, color: active ? AppColors.primary : AppColors.muted),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: AppTheme.body(
                            size: 10,
                            weight: FontWeight.w600,
                            color: active ? AppColors.primary : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
