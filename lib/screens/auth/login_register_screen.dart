import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_navigation.dart';
import '../../providers/app_state.dart';
import '../../services/travel_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLogin = true;
  bool loading = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      final data = isLogin
          ? await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text)
          : await AuthService.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      final appState = context.read<AppState>();
      await appState.setSession(data['access_token'], AppUser.fromJson(data['user']));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 72, 28, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.gradEnd, AppColors.bg],
                stops: [0.0, 0.55, 0.55],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  isLogin ? 'Chào Mừng Trở Lại!' : 'Tạo Tài Khoản',
                  style: AppTheme.heading(size: 26, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'AI Travel Advisor — Tư vấn du lịch thông minh',
                  style: AppTheme.body(size: 13, color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isLogin) ...[
                      Text('HỌ VÀ TÊN', style: AppTheme.label(color: const Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text('EMAIL', style: AppTheme.label(color: const Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 16),
                    Text('MẬT KHẨU', style: AppTheme.label(color: const Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline_rounded)),
                    ),
                    if (isLogin) ...[
                      const SizedBox(height: 8),
                      Text('Demo: admin@travel.ai / admin123', style: AppTheme.body(size: 12, color: AppColors.muted)),
                    ],
                    const SizedBox(height: 24),
                    AppPrimaryButton(
                      label: isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                      loading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    AppPrimaryButton(label: 'Bỏ qua và trải nghiệm ngay', outline: true, onPressed: _skipLogin),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('HOẶC', style: AppTheme.label()),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isLogin ? 'Chưa có tài khoản? ' : 'Đã có tài khoản? ', style: AppTheme.body(size: 13, color: AppColors.muted)),
                        GestureDetector(
                          onTap: () => setState(() => isLogin = !isLogin),
                          child: Text(
                            isLogin ? 'Đăng ký ngay' : 'Đăng nhập',
                            style: AppTheme.body(size: 13, color: AppColors.primary, weight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
