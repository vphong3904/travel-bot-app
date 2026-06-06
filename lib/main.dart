import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/auth/login_register_screen.dart';
import 'main_navigation.dart';
import 'theme/app_theme.dart';
import 'widgets/common_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadSession(),
      child: const TravelChatbotApp(),
    ),
  );
}

class TravelChatbotApp extends StatelessWidget {
  const TravelChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Travel Advisor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    context.read<AppState>().loadSession().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    final loggedIn = context.watch<AppState>().isLoggedIn;
    return loggedIn ? const MainNavigationScreen() : const LoginRegisterScreen();
  }
}
