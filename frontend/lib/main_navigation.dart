// lib/main_navigation.dart
// MainNavigationScreen — Bottom navigation chính của mobile app.
// Tab order: Khám phá | AI Chat | Dịch vụ | Hồ sơ
// Web Admin chạy riêng qua lib/main_admin.dart (Flutter Web target).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
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
    // Suppress unused import warning — AppState still needed for user context elsewhere
    context.watch<AppState>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _destinations,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
