// lib/features/auth/screens/reset_password_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart' show _AuthCard;

class ResetPasswordScreen extends ConsumerStatefulWidget {
  /// Token từ query params ?token=xxx (đọc bởi GoRouter)
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Guard: nếu token rỗng thì redirect về forgot-password
    if (widget.token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/forgot-password');
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await ref.read(authRepositoryProvider).resetPassword(
        widget.token,
        _passCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu đã được đặt lại thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } on DioException catch (e) {
      final detail = (e.response?.data as Map<String, dynamic>?)?['detail'];
      setState(() {
        _isLoading = false;
        _error = detail?.toString() ??
            'Link đã hết hạn hoặc không hợp lệ. Vui lòng yêu cầu link mới.';
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
            child: _AuthCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_person_outlined,
                        size: 48, color: Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    const Text(
                      'Đặt lại mật khẩu',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chọn mật khẩu mới cho tài khoản của bạn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // Mật khẩu mới
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePass ? 'Hiện' : 'Ẩn',
                          icon: Icon(_obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                        if (v.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Xác nhận mật khẩu
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirm ? 'Hiện' : 'Ẩn',
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) =>
                          v != _passCtrl.text ? 'Mật khẩu không khớp' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    // Password strength hint
                    const SizedBox(height: 8),
                    Text(
                      'Mật khẩu phải có ít nhất 8 ký tự.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),

                    // Error banner
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade600, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                    color: Colors.red.shade700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Link yêu cầu lại nếu token expired
                      if (_error!.contains('hết hạn') || _error!.contains('hợp lệ'))
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TextButton(
                            onPressed: () => context.go('/forgot-password'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Yêu cầu link mới →'),
                          ),
                        ),
                    ],

                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Xác nhận đặt lại mật khẩu',
                              style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
