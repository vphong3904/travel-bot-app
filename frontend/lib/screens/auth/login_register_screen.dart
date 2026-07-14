// lib/screens/auth/login_register_screen.dart
//
// Màn hình xác thực — hỗ trợ 3 flow:
//   1. Login (email + password)
//   2. Register (2 bước: form → OTP → tạo tk)
//   3. Google Sign-In (1 bước, không cần OTP)
//   4. Forgot Password (email → OTP → mật khẩu mới)
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../main_navigation.dart';
import '../../providers/app_state.dart';
import '../../services/auth_api_service.dart';
import '../../services/api_service.dart';
import '../../services/google_sign_in_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/google_web_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum quản lý state màn hình
// ─────────────────────────────────────────────────────────────────────────────

enum _AuthMode {
  login,
  register,        // Bước 1: form thông tin
  registerOtp,     // Bước 2: nhập OTP
  forgotPassword,  // Bước 1: nhập email
  resetOtp,        // Bước 2: nhập OTP + mật khẩu mới
}

// ─────────────────────────────────────────────────────────────────────────────

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  _AuthMode _mode = _AuthMode.login;
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  // Controllers
  final _usernameCtrl   = TextEditingController();
  final _fullNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _otpCtrl        = TextEditingController();
  final _newPassCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Cached email (dùng để hiển thị ở bước OTP sau khi chuyển mode)
  String _cachedEmail = '';

  // Google Sign-In — trên Web, kết quả sign-in đến qua stream (nút native
  // Google render sẵn), không qua Future trả về như Android/iOS.
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSub;

  @override
  void initState() {
    super.initState();
    GoogleSignInService.ensureInitialized().then((_) {
      if (!kIsWeb || !mounted) return;
      _googleAuthSub = GoogleSignIn.instance.authenticationEvents.listen(
        (event) {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            _handleGoogleIdToken(event.user.authentication.idToken);
          }
        },
        onError: (_) {},
      );
    }).catchError((_) {
      // Google Sign-In chưa cấu hình đúng (client_id sai/thiếu) — bỏ qua,
      // người dùng vẫn đăng nhập được bằng email/password.
    });
  }

  @override
  void dispose() {
    _googleAuthSub?.cancel();
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _skipLogin() => _goHome();

  void _setMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _otpCtrl.clear();
    });
  }

  // ── Error / Success snackbar ───────────────────────────────────────────────

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _extractError(Object e) {
    if (e is ApiException) return e.message;
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.substring(11) : s;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLOW 1: Login
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _doLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final result = await AuthApiService.login(
        _emailCtrl.text,
        _passCtrl.text,
      );
      if (!mounted) return;
      await context.read<AppState>().setSession(
            accessToken: result.tokens.accessToken,
            refreshToken: result.tokens.refreshToken,
            user: result.user,
          );
      _goHome();
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLOW 2: Register — Bước 1 (gửi OTP)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _doRegisterSendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await AuthApiService.registerSendOtp(
        username: _usernameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
        fullName: _fullNameCtrl.text.trim().isEmpty ? null : _fullNameCtrl.text,
      );
      _cachedEmail = _emailCtrl.text.trim().toLowerCase();
      _showSuccess('Mã OTP đã gửi đến ${_cachedEmail}');
      _setMode(_AuthMode.registerOtp);
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLOW 2: Register — Bước 2 (xác nhận OTP)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _doRegisterConfirm() async {
    final otpErr = AuthValidators.validateOtp(_otpCtrl.text);
    if (otpErr != null) { _showError(otpErr); return; }

    setState(() => _loading = true);
    try {
      final result = await AuthApiService.registerConfirm(
        username: _usernameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
        otpCode: _otpCtrl.text.trim(),
        fullName: _fullNameCtrl.text.trim().isEmpty ? null : _fullNameCtrl.text,
      );
      if (!mounted) return;
      await context.read<AppState>().setSession(
            accessToken: result.tokens.accessToken,
            refreshToken: result.tokens.refreshToken,
            user: result.user,
          );
      _goHome();
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLOW 3: Google Sign-In
  // ─────────────────────────────────────────────────────────────────────────

  /// Android/iOS: mở UI chọn tài khoản Google trực tiếp.
  /// Trên Web, nút Google native tự xử lý — xem `_googleAuthSub` ở initState.
  Future<void> _doGoogleLogin() async {
    setState(() => _loading = true);
    try {
      final idToken = await GoogleSignInService.signInNative();
      if (idToken == null) return; // người dùng bấm huỷ
      await _handleGoogleIdToken(idToken);
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Dùng chung cho cả luồng mobile (`_doGoogleLogin`) lẫn luồng Web (stream
  /// `authenticationEvents` khi người dùng bấm nút Google native).
  Future<void> _handleGoogleIdToken(String? idToken) async {
    if (idToken == null) {
      _showError('Không lấy được Google token. Vui lòng thử lại.');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await AuthApiService.loginWithGoogle(idToken);
      if (!mounted) return;
      await context.read<AppState>().setSession(
            accessToken: result.tokens.accessToken,
            refreshToken: result.tokens.refreshToken,
            user: result.user,
          );
      _goHome();
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLOW 4: Forgot Password — Bước 1 (gửi OTP)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _doForgotPassword() async {
    final emailErr = AuthValidators.validateEmail(_emailCtrl.text);
    if (emailErr != null) { _showError(emailErr); return; }

    setState(() => _loading = true);
    try {
      await AuthApiService.forgotPassword(_emailCtrl.text);
      _cachedEmail = _emailCtrl.text.trim().toLowerCase();
      _showSuccess('Nếu email tồn tại, mã OTP đã được gửi');
      _setMode(_AuthMode.resetOtp);
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLOW 4: Forgot Password — Bước 2 (đặt mật khẩu mới)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _doResetPassword() async {
    final otpErr = AuthValidators.validateOtp(_otpCtrl.text);
    if (otpErr != null) { _showError(otpErr); return; }

    final passErr = AuthValidators.validatePassword(_newPassCtrl.text);
    if (passErr != null) { _showError(passErr); return; }

    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthApiService.resetPassword(
        email: _cachedEmail,
        otpCode: _otpCtrl.text.trim(),
        newPassword: _newPassCtrl.text,
      );
      _showSuccess('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.');
      _emailCtrl.text = _cachedEmail;
      _passCtrl.clear();
      _setMode(_AuthMode.login);
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resend OTP
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _resendOtp(String purpose) async {
    setState(() => _loading = true);
    try {
      await AuthApiService.resendOtp(email: _cachedEmail, purpose: purpose);
      _showSuccess('Đã gửi lại mã OTP đến $_cachedEmail');
    } catch (e) {
      _showError(_extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                _buildLogo(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 32),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo ───────────────────────────────────────────────────────────────────

  Widget _buildLogo() => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 20,
              )
            ],
          ),
          child: const Icon(Icons.travel_explore_rounded,
              size: 56, color: AppColors.primary),
        ),
      );

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    final titles = {
      _AuthMode.login:          'Chào Mừng Trở Lại!',
      _AuthMode.register:       'Tạo Tài Khoản Mới',
      _AuthMode.registerOtp:    'Xác Nhận Email',
      _AuthMode.forgotPassword: 'Quên Mật Khẩu',
      _AuthMode.resetOtp:       'Đặt Lại Mật Khẩu',
    };
    return Column(children: [
      Text(
        titles[_mode] ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.dark),
      ),
      const SizedBox(height: 8),
      Text(
        'PDTrip AI — Tư vấn du lịch Việt Nam',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.muted, fontSize: 14),
      ),
    ]);
  }

  // ── Body dispatch ──────────────────────────────────────────────────────────

  Widget _buildBody() {
    switch (_mode) {
      case _AuthMode.login:
        return _buildLoginForm();
      case _AuthMode.register:
        return _buildRegisterForm();
      case _AuthMode.registerOtp:
        return _buildOtpForm(
          purpose: 'Xác nhận tài khoản',
          hint: 'Nhập mã OTP gửi đến $_cachedEmail để hoàn tất đăng ký.',
          onSubmit: _doRegisterConfirm,
          onResend: () => _resendOtp('register'),
          onBack: () => _setMode(_AuthMode.register),
        );
      case _AuthMode.forgotPassword:
        return _buildForgotPasswordForm();
      case _AuthMode.resetOtp:
        return _buildResetPasswordForm();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Form: Login
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLoginForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _emailField(),
          const SizedBox(height: 16),
          _passwordField(_passCtrl, 'Mật khẩu *', obscure: _obscurePass,
              toggle: () => setState(() => _obscurePass = !_obscurePass),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                return null;
              }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _setMode(_AuthMode.forgotPassword),
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton('Đăng Nhập', _doLogin),
          const SizedBox(height: 12),
          _skipButton(),
          const SizedBox(height: 24),
          _toggleMode(
            question: 'Chưa có tài khoản? ',
            action: 'Đăng ký ngay',
            onTap: () => _setMode(_AuthMode.register),
          ),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Form: Register (Bước 1)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildRegisterForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(
              labelText: 'Username *',
              hintText: 'vd: nguyen_van_a',
              prefixIcon: Icon(Icons.alternate_email),
              helperText: 'Chữ thường, số, _ hoặc - (3-50 ký tự)',
            ),
            validator: AuthValidators.validateUsername,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-]')),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fullNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          _emailField(),
          const SizedBox(height: 16),
          _passwordField(
            _passCtrl,
            'Mật khẩu *',
            obscure: _obscurePass,
            toggle: () => setState(() => _obscurePass = !_obscurePass),
            validator: AuthValidators.validatePassword,
            showStrength: true,
          ),
          const SizedBox(height: 8),
          Text(
            '✓ Tối thiểu 8 ký tự  ✓ Chữ HOA + thường  ✓ Số  ✓ Ký tự đặc biệt',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          _primaryButton('Tiếp Tục — Nhận OTP', _doRegisterSendOtp),
          const SizedBox(height: 24),
          _toggleMode(
            question: 'Đã có tài khoản? ',
            action: 'Đăng nhập',
            onTap: () => _setMode(_AuthMode.login),
          ),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Form: OTP (tái sử dụng cho cả register và reset)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildOtpForm({
    required String purpose,
    required String hint,
    required VoidCallback onSubmit,
    required VoidCallback onResend,
    required VoidCallback onBack,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(hint,
                      style: const TextStyle(fontSize: 14, color: AppColors.dark)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Mã OTP',
              hintText: '000000',
              counterText: '',
            ),
            validator: AuthValidators.validateOtp,
          ),
          const SizedBox(height: 8),
          Text(
            'Mã có hiệu lực trong 10 phút',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          _primaryButton('Xác Nhận', onSubmit),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : onResend,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Gửi lại mã OTP'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : onBack,
            child: const Text('← Quay lại'),
          ),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Form: Forgot Password (Bước 1)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildForgotPasswordForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nhập email đã đăng ký. Chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          _emailField(),
          const SizedBox(height: 24),
          _primaryButton('Gửi Mã OTP', _doForgotPassword),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : () => _setMode(_AuthMode.login),
            child: const Text('← Quay lại đăng nhập'),
          ),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Form: Reset Password (Bước 2: OTP + mật khẩu mới)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildResetPasswordForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Nhập mã OTP gửi đến $_cachedEmail và mật khẩu mới.',
              style: const TextStyle(fontSize: 14, color: AppColors.dark),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Mã OTP *',
              hintText: '000000',
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          _passwordField(
            _newPassCtrl,
            'Mật khẩu mới *',
            obscure: _obscureNewPass,
            toggle: () => setState(() => _obscureNewPass = !_obscureNewPass),
            validator: AuthValidators.validatePassword,
            showStrength: true,
          ),
          const SizedBox(height: 16),
          _passwordField(
            _confirmPassCtrl,
            'Xác nhận mật khẩu *',
            obscure: _obscureConfirmPass,
            toggle: () =>
                setState(() => _obscureConfirmPass = !_obscureConfirmPass),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (v != _newPassCtrl.text) return 'Mật khẩu xác nhận không khớp';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            '✓ Tối thiểu 8 ký tự  ✓ Chữ HOA + thường  ✓ Số  ✓ Ký tự đặc biệt',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          _primaryButton('Đặt Lại Mật Khẩu', _doResetPassword),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : () => _resendOtp('reset_password'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Gửi lại OTP'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : () => _setMode(_AuthMode.login),
            child: const Text('← Quay lại đăng nhập'),
          ),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Shared widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _emailField() => TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email *',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: AuthValidators.validateEmail,
      );

  Widget _passwordField(
    TextEditingController ctrl,
    String label, {
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
    bool showStrength = false,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: ctrl,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: toggle,
              ),
            ),
            validator: validator,
            onChanged: showStrength ? (_) => setState(() {}) : null,
          ),
          if (showStrength && ctrl.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            _PasswordStrengthBar(password: ctrl.text),
          ],
        ],
      );

  Widget _primaryButton(String label, VoidCallback onTap) => ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
        ),
        child: _loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  // Trên Web, Google bắt buộc dùng nút native (renderButton) — không thể tự vẽ
  // nút custom rồi tự gọi authenticate() như Android/iOS.
  Widget _googleButton() => kIsWeb
      ? SizedBox(width: double.infinity, child: buildGoogleWebButton())
      : OutlinedButton.icon(
          onPressed: _loading ? null : _doGoogleLogin,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          icon: const Icon(Icons.g_mobiledata_rounded, size: 26, color: Color(0xFFEA4335)),
          label: const Text(
            'Tiếp tục với Google',
            style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w600),
          ),
        );

  Widget _skipButton() => OutlinedButton(
        onPressed: _skipLogin,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: const Text('Bỏ qua — trải nghiệm với tư cách khách'),
      );

  Widget _toggleMode({
    required String question,
    required String action,
    required VoidCallback onTap,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(question, style: TextStyle(color: AppColors.muted)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Password Strength Bar
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  @override
  Widget build(BuildContext context) {
    final score = AuthValidators.passwordStrengthScore(password);
    final labels = ['Rất yếu', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'];
    final colors = [
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.yellow.shade700,
      Colors.lightGreen.shade600,
      Colors.green.shade700,
    ];

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (score + 1) / 5,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation(colors[score]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          labels[score],
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors[score]),
        ),
      ],
    );
  }
}
