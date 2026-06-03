import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_navigation.dart';
import '../../providers/app_state.dart';
import '../../services/travel_api.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _skipLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
  }

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
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 20)],
                  ),
                  child: const Icon(Icons.travel_explore_rounded, size: 56, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isLogin ? 'Chào Mừng Trở Lại!' : 'Tạo Tài Khoản Mới',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
              const SizedBox(height: 8),
              Text(
                'AI Travel Advisor - Tư vấn du lịch thông minh',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 32),
              if (!isLogin) ...[
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 8),
              if (isLogin)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('Demo: admin@travel.ai / admin123', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                child: loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isLogin ? 'Đăng Nhập' : 'Đăng Ký', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _skipLogin,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Bỏ qua và trải nghiệm ngay'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isLogin ? 'Chưa có tài khoản? ' : 'Đã có tài khoản? '),
                  GestureDetector(
                    onTap: () => setState(() => isLogin = !isLogin),
                    child: Text(isLogin ? 'Đăng ký ngay' : 'Đăng nhập', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
