import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'admin/providers/auth_provider.dart';
import 'admin/widgets/admin_layout.dart';
import 'admin/screens/login_screen.dart';
import 'admin/screens/dashboard_screen.dart';
import 'admin/screens/users_screen.dart';
import 'admin/screens/chat_screen.dart';
import 'admin/screens/knowledge_screen.dart';
import 'admin/screens/content_screen.dart';
import 'admin/screens/feedback_screen.dart';
import 'admin/screens/media_screen.dart';
import 'admin/screens/rag_monitoring_screen.dart';
import 'admin/screens/city_mapping_screen.dart';
import 'admin/screens/intent_patterns_screen.dart';
import 'admin/screens/system_config_screen.dart';

GoRouter buildAdminRouter(AdminAuthProvider auth) => GoRouter(
  initialLocation: '/admin',
  refreshListenable: auth,
  redirect: (BuildContext context, GoRouterState state) {
    final isLoginRoute = state.matchedLocation == '/admin/login';
    if (!auth.isLoggedIn && !isLoginRoute) return '/admin/login';
    if (auth.isLoggedIn && isLoginRoute) return '/admin';
    return null;
  },
  routes: [
    GoRoute(
      path: '/admin/login',
      builder: (_, __) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AdminLayout(child: child),
      routes: [
        GoRoute(path: '/admin',                builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/admin/users',          builder: (_, __) => const UsersScreen()),
        GoRoute(path: '/admin/chat',           builder: (_, __) => const ChatScreen()),
        GoRoute(path: '/admin/knowledge',      builder: (_, __) => const KnowledgeScreen()),
        GoRoute(path: '/admin/content',        builder: (_, __) => const ContentScreen()),
        GoRoute(path: '/admin/feedback',       builder: (_, __) => const FeedbackScreen()),
        GoRoute(path: '/admin/media',          builder: (_, __) => const MediaScreen()),
        GoRoute(path: '/admin/rag-monitoring', builder: (_, __) => const RagMonitoringScreen()),
        GoRoute(path: '/admin/city-mapping',   builder: (_, __) => const CityMappingScreen()),
        GoRoute(path: '/admin/intent-patterns',builder: (_, __) => const IntentPatternsScreen()),
        GoRoute(path: '/admin/system-config',  builder: (_, __) => const SystemConfigScreen()),
      ],
    ),
  ],
);
