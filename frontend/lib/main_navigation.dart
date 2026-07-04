// lib/main_navigation.dart
// MainNavigationScreen — Bottom navigation chính của mobile app.
// Layout mới (5 slot): Khám phá | Tìm kiếm | [AI Chat nổi giữa] | Chuyến đi | Hồ sơ
//   - 4 tab thường dùng IndexedStack (giữ state khi chuyển tab)
//   - Nút AI Chat ở giữa là nút nổi (raised) → push ChatBotScreen fullscreen
// Web Admin chạy riêng qua lib/main_admin.dart (Flutter Web target).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'widgets/common_widgets.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/trip/trip_screen.dart';
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
    _currentIndex = widget.initialIndex.clamp(0, 3);
  }

  // 4 tab thường (index 0..3). AI Chat (giữa) không nằm trong stack.
  static const _screens = [
    HomeScreen(),
    SearchScreen(embedded: true),
    TripScreen(),
    ProfileScreen(),
  ];

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatBotScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>(); // giữ user context cho các tab con

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTabSelected: (i) => setState(() => _currentIndex = i),
        onChatTapped: _openChat,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Custom bottom bar với nút AI nổi ở giữa
// ─────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onChatTapped;

  const _BottomBar({
    required this.currentIndex,
    required this.onTabSelected,
    required this.onChatTapped,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Khám phá',
              selected: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavItem(
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: 'Tìm kiếm',
              selected: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _ChatButton(onTap: onChatTapped),
            _NavItem(
              icon: Icons.bookmark_outline_rounded,
              activeIcon: Icons.bookmark_rounded,
              label: 'Chuyến đi',
              selected: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Hồ sơ',
              selected: currentIndex == 3,
              onTap: () => onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradStart, AppColors.gradEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(height: 1),
                const Text(
                  'AI Chat',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
