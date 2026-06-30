// lib/main.dart
// ─────────────────────────────────────────────────────────────────────────────
// Entry point của TripMate AI.
//
// ⚠️  KHÔNG đặt routing logic ở đây.
//     SplashScreen tự load session rồi navigate tới Login hoặc Home.
//
// Trước đây bị lỗi: Consumer<AppState> ở home → khi isLoggedIn=false thì vào
// LoginScreen, khi true thì vào SplashScreen (ngược hoàn toàn, và SplashScreen
// không navigate đi đâu cả).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'providers/chat_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // AppState: quản lý session (token + user)
        // Không gọi loadSession() ở đây — SplashScreen sẽ tự gọi
        ChangeNotifierProvider(create: (_) => AppState()),
        // ChatProvider: UI state của màn hình chat
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const TravelChatbotApp(),
    ),
  );
}

class TravelChatbotApp extends StatelessWidget {
  const TravelChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [P4] đọc themeMode từ AppState để hỗ trợ dark mode (persist + đổi tức thì).
    final appState = context.watch<AppState>();
    return MaterialApp(
      title: 'TripMate AI',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: appState.themeMode,
      // SplashScreen là màn hình duy nhất được đặt ở đây.
      // Mọi routing tiếp theo đều do SplashScreen và các screen khác xử lý.
      home: const SplashScreen(),
    );
  }

  ThemeData _buildDarkTheme() {
    const bg = Color(0xFF0F172A);
    const surface = Color(0xFF1E293B);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.dark,
        primary: const Color(0xFF60A5FA),
        secondary: const Color(0xFFFB923C),
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: surface),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: const Color(0xFF60A5FA).withValues(alpha: 0.18),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        primary: const Color(0xFF2563EB),
        secondary: const Color(0xFFF97316),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB));
          }
          return TextStyle(fontSize: 12, color: Colors.grey.shade600);
        }),
      ),
    );
  }
}