// lib/admin/admin_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'shared/providers/auth_provider.dart';
import 'web/screens/login_screen.dart';
import 'web/screens/forgot_password_screen.dart';
import 'web/screens/reset_password_screen.dart';
import 'web/screens/dashboard_screen.dart';
import 'web/screens/users_screen.dart';
import 'web/screens/chat_screen.dart';
import 'web/screens/knowledge_screen.dart';
import 'web/screens/kb_health_screen.dart';
import 'web/screens/rag_monitoring_screen.dart';
import 'web/screens/city_mapping_screen.dart';
import 'web/screens/intent_patterns_screen.dart';
import 'web/screens/destinations_screen.dart';
import 'web/screens/hotels_screen.dart';
import 'web/screens/tours_screen.dart';
import 'web/screens/foods_screen.dart';
import 'web/screens/restaurants_screen.dart';
import 'web/screens/shopping_screen.dart';
import 'web/screens/itineraries_screen.dart';
import 'web/screens/events_screen.dart';
import 'web/screens/transport_screen.dart';
import 'web/screens/content_options_screen.dart';
import 'web/screens/chatbot_test_screen.dart';
import 'web/screens/media_screen.dart';
import 'web/widgets/admin_layout.dart';

/// Provider cho GoRouter — reactive theo authProvider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password');

      if (!isLoggedIn && !isAuthRoute) return '/login';
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

      // Protected routes — wraps in AdminLayout
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/users',
            name: 'users',
            builder: (_, __) => const UsersScreen(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (_, __) => const ChatScreen(),
          ),
          GoRoute(
            path: '/knowledge',
            name: 'knowledge',
            builder: (_, __) => const KnowledgeScreen(),
          ),
          GoRoute(
            path: '/knowledge/health',
            name: 'knowledge-health',
            builder: (_, __) => const KbHealthScreen(),
          ),
          GoRoute(
            path: '/rag-monitoring',
            name: 'rag-monitoring',
            builder: (_, __) => const RagMonitoringScreen(),
          ),
          GoRoute(
            path: '/city-mapping',
            name: 'city-mapping',
            builder: (_, __) => const CityMappingScreen(),
          ),
          GoRoute(
            path: '/intent-patterns',
            name: 'intent-patterns',
            builder: (_, __) => const IntentPatternsScreen(),
          ),
          GoRoute(
            path: '/content-options',
            name: 'content-options',
            builder: (_, __) => const ContentOptionsScreen(),
          ),
          GoRoute(
            path: '/chatbot-test',
            name: 'chatbot-test',
            builder: (_, __) => const ChatbotTestScreen(),
          ),
          GoRoute(
            path: '/media',
            name: 'media',
            builder: (_, __) => const MediaScreen(),
          ),
          GoRoute(
            path: '/content/destinations',
            name: 'content-destinations',
            builder: (_, __) => const DestinationsScreen(),
          ),
          GoRoute(
            path: '/content/hotels',
            name: 'content-hotels',
            builder: (_, __) => const HotelsScreen(),
          ),
          GoRoute(
            path: '/content/tours',
            name: 'content-tours',
            builder: (_, __) => const ToursScreen(),
          ),
          GoRoute(
            path: '/content/foods',
            name: 'content-foods',
            builder: (_, __) => const FoodsScreen(),
          ),
          GoRoute(
            path: '/content/restaurants',
            name: 'content-restaurants',
            builder: (_, __) => const RestaurantsScreen(),
          ),
          GoRoute(
            path: '/content/shopping',
            name: 'content-shopping',
            builder: (_, __) => const ShoppingScreen(),
          ),
          GoRoute(
            path: '/content/itineraries',
            name: 'content-itineraries',
            builder: (_, __) => const ItinerariesScreen(),
          ),
          GoRoute(
            path: '/content/events',
            name: 'content-events',
            builder: (_, __) => const EventsScreen(),
          ),
          GoRoute(
            path: '/content/transport',
            name: 'content-transport',
            builder: (_, __) => const TransportScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Trang không tồn tại',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Về trang đăng chủ'),
            ),
          ],
        ),
      ),
    ),
  );
});
