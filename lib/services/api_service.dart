import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api';
      default:
        return 'http://localhost:8000/api';
    }
  }
}

class ApiClient {
  static String? token;

  static Map<String, String> jsonHeaders({bool withAuth = true}) => {
        'Content-Type': 'application/json',
        if (withAuth && token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };
}
