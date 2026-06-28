// lib/router.dart
// Chỉ phần auth routes và redirect guard — tích hợp vào GoRouter root của dự án

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';

/// Provider cho GoRouter — dùng ref.watch để router reactive theo authProvider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password');

      // Chưa đăng nhập + không ở auth route → về login
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Đã đăng nhập mà vào trang login → về dashboard
      if (isLoggedIn && state.matchedLocation == '/login') return '/dashboard';

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),

      // Protected routes (thêm các route dashboard, users, ... ở đây)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (_, __) => const _PlaceholderScreen(title: 'Dashboard'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Trang không tồn tại', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Về trang đăng nhập'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Placeholder — xóa khi TA-005 (Dashboard) hoàn thành
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('$title — Coming soon (TA-005)')),
  );
}
