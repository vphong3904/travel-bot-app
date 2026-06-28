// lib/main_navigation.dart
// ─────────────────────────────────────────────────────────────────────────────
// MainNavigationScreen — Bottom navigation chính của app.
//
// Tab order: Khám phá | AI Chat | Dịch vụ | Hồ sơ
// Admin FAB chỉ hiện nếu user.isAdmin == true
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'widgets/common_widgets.dart';

class MainNavigationScreen extends StatefulWidget {
  /// Tab khởi đầu (mặc định 0 = Home)
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  static const _screens = [
    HomeScreen(),
    ChatBotScreen(),
    ServicesScreen(),
    ProfileScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Khám phá',
    ),
    NavigationDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: 'AI Chat',
    ),
    NavigationDestination(
      icon: Icon(Icons.room_service_outlined),
      selectedIcon: Icon(Icons.room_service),
      label: 'Dịch vụ',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Hồ sơ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Chỉ watch isAdmin để không rebuild toàn bộ khi user thay đổi minor field
    final isAdmin = context.select<AppState, bool>(
      (s) => s.user?.isAdmin ?? false,
    );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: isAdmin ? _buildAdminFab() : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _destinations,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildAdminFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      ),
      backgroundColor: AppColors.dark,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.admin_panel_settings_outlined),
      label: const Text('Admin', style: TextStyle(fontWeight: FontWeight.w600)),
      elevation: 2,
    );
  }
}