// lib/screens/auth/login_register_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// LoginRegisterScreen — đăng nhập / đăng ký với backend thật.
//
// Flow Login:
//   1. AuthApiService.login() → tokens + user (gọi /me bên trong)
//   2. AppState.setSession()
//   3. Navigate MainNavigationScreen
//
// Flow Register:
//   1. AuthApiService.register() → UserResponse (201)
//   2. Tự động login luôn để lấy token
//   3. AppState.setSession() → Navigate
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_navigation.dart';
import '../../providers/app_state.dart';
import '../../services/auth_api_service.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePass = true;

  final _usernameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập đầy đủ email và mật khẩu');
      return;
    }
    if (!_isLogin && _usernameCtrl.text.trim().isEmpty) {
      _showError('Vui lòng nhập username');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await _doLogin(email, password);
      } else {
        await _doRegister(email, password);
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doLogin(String email, String password) async {
    final result = await AuthApiService.login(email, password);
    if (!mounted) return;
    await context.read<AppState>().setSession(
          accessToken: result.tokens.accessToken,
          refreshToken: result.tokens.refreshToken,
          user: result.user,
        );
    _navigateHome();
  }

  Future<void> _doRegister(String email, String password) async {
    final username = _usernameCtrl.text.trim();
    final fullName = _fullNameCtrl.text.trim();

    // 1. Đăng ký
    await AuthApiService.register(
      username: username,
      email: email,
      password: password,
      fullName: fullName.isEmpty ? null : fullName,
    );

    // 2. Tự login để lấy token
    final result = await AuthApiService.login(email, password);
    if (!mounted) return;
    await context.read<AppState>().setSession(
          accessToken: result.tokens.accessToken,
          refreshToken: result.tokens.refreshToken,
          user: result.user,
        );
    _navigateHome();
  }

  void _navigateHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20)
                    ],
                  ),
                  child: const Icon(Icons.travel_explore_rounded,
                      size: 56, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _isLogin ? 'Chào Mừng Trở Lại!' : 'Tạo Tài Khoản Mới',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark),
              ),
              const SizedBox(height: 8),
              Text(
                'TripMate AI — Tư vấn du lịch Việt Nam',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // ── Form Fields ──────────────────────────────────────────────
              if (!_isLogin) ...[
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username *',
                    hintText: 'vd: phong123',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fullNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên (không bắt buộc)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),

              if (_isLogin) ...[
                const SizedBox(height: 8),
                Text(
                  'Mật khẩu tối thiểu 8 ký tự',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
              const SizedBox(height: 24),

              // ── Submit Button ────────────────────────────────────────────
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        _isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _skipLogin,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                child: const Text('Bỏ qua — trải nghiệm với tư cách khách'),
              ),
              const SizedBox(height: 24),

              // ── Toggle Login / Register ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? 'Chưa có tài khoản? ' : 'Đã có tài khoản? '),
                  GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Đăng ký ngay' : 'Đăng nhập',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}