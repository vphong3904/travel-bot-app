// lib/screens/splash/splash_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen — màn hình khởi động.
//
// Flow:
//   1. Hiển thị animation + logo
//   2. Chờ AppState.loadSession() hoàn tất (đọc token từ storage, gọi /auth/me)
//   3. Nếu đã đăng nhập → MainNavigationScreen
//      Nếu chưa         → LoginRegisterScreen
//
// ⚠️  Không dùng Consumer ở đây — tự navigate sau khi Future hoàn tất
//     để tránh rebuild loop.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_register_screen.dart';
import '../../main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.75, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    // Bắt đầu load session song song với animation
    _init();
  }

  Future<void> _init() async {
    final appState = context.read<AppState>();

    // Chạy song song: minimum splash time + load session
    await Future.wait([
      appState.loadSession(),
      Future.delayed(const Duration(milliseconds: 2000)), // tối thiểu 2s
    ]);

    if (!mounted) return;

    // Navigate dựa trên trạng thái session
    final destination = appState.isLoggedIn
        ? const MainNavigationScreen()
        : const LoginRegisterScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animated
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // App name
            FadeTransition(
              opacity: _fade,
              child: const Text(
                'TripMate AI',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            FadeTransition(
              opacity: _fade,
              child: const Text(
                'Tư vấn du lịch Việt Nam thông minh',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 56),

            // Loading indicator
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đang khởi động...',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}