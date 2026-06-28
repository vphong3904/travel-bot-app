// lib/features/auth/screens/forgot_password_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/data/auth_repository.dart';
import '../widgets/auth_card.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).forgotPassword(_emailCtrl.text.trim());
      if (mounted) setState(() { _isLoading = false; _submitted = true; });
    } on DioException catch (e) {
      final detail = (e.response?.data as Map<String, dynamic>?)?['detail'];
      setState(() {
        _isLoading = false;
        _error = detail?.toString() ?? 'Gửi email thất bại. Vui lòng thử lại.';
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Không thể kết nối. Kiểm tra mạng và thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AuthCard(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _submitted ? _SuccessView(email: _emailCtrl.text) : _FormView(
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  isLoading: _isLoading,
                  error: _error,
                  onSubmit: _submit,
                  onClearError: () => setState(() => _error = null),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onClearError;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
    required this.onClearError,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey('form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset_outlined, size: 48, color: Color(0xFF2563EB)),
          const SizedBox(height: 12),
          const Text(
            'Quên mật khẩu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhập email tài khoản và chúng tôi sẽ gửi link đặt lại mật khẩu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
              if (!v.contains('@')) return 'Email không hợp lệ';
              return null;
            },
            onChanged: (_) => onClearError(),
          ),

          // Error banner
          if (error != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: error!),
          ],

          const SizedBox(height: 20),
          FilledButton(
            onPressed: isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Gửi link đặt lại'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('← Quay lại đăng nhập'),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 56, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Kiểm tra email của bạn',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Link đặt lại mật khẩu đã được gửi đến $email.\nKiểm tra cả thư mục spam nếu không thấy.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('← Quay lại đăng nhập'),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
