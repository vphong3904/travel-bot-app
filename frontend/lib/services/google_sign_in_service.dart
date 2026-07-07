// lib/services/google_sign_in_service.dart
//
// Wrapper cho package google_sign_in (v7 API — khác hẳn API cũ v6).
//
// Lưu ý quan trọng: trên Web, GoogleSignIn.instance.authenticate() KHÔNG được
// hỗ trợ (Google bắt buộc dùng nút "Sign in with Google" render sẵn qua FedCM/
// Google Identity Services vì lý do bảo mật) — chỉ Android/iOS mới gọi được
// authenticate() trực tiếp. Xem widgets/google_web_button.dart cho luồng Web.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Client ID của OAuth Client loại **Web application** — PHẢI khớp với
/// GOOGLE_CLIENT_ID ở backend/.env vì backend verify id_token theo audience này.
///
/// Trên Android/iOS, đây được truyền làm `serverClientId` để id_token trả về có
/// aud = web client (backend verify đúng). Android còn cần một OAuth Client loại
/// **Android** riêng (package name + SHA-1) trong cùng project để Google nhận
/// diện app — client Android đó KHÔNG dùng làm audience, không cần điền ở đây.
class GoogleSignInConfig {
  static const String webClientId =
      '573610588009-ko1jpgsvpl4dnehrr6l0m9g2vogrk9ft.apps.googleusercontent.com';
}

class GoogleSignInService {
  static bool _initialized = false;
  static Future<void>? _initFuture;

  /// Gọi 1 lần duy nhất trước khi dùng bất kỳ API nào khác của GoogleSignIn.
  /// An toàn khi gọi nhiều lần (idempotent).
  static Future<void> ensureInitialized() {
    if (_initialized) return Future.value();
    return _initFuture ??= GoogleSignIn.instance
        .initialize(
          // Web: clientId lấy từ meta tag trong index.html là đủ, nhưng truyền
          //   ở đây cho chắc. Android/iOS KHÔNG được set clientId (chỉ dùng
          //   serverClientId) — set clientId = web client trên Android sẽ gây
          //   clientConfigurationError.
          clientId: kIsWeb ? GoogleSignInConfig.webClientId : null,
          serverClientId: GoogleSignInConfig.webClientId,
        )
        .then((_) => _initialized = true);
  }

  /// Luồng Android/iOS: mở UI chọn tài khoản Google trực tiếp.
  /// Trả về id_token, hoặc null nếu người dùng huỷ.
  static Future<String?> signInNative() async {
    await ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}
