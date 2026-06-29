// lib/admin/shared/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

const _kApiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api',
);

final BaseOptions _baseOptions = BaseOptions(
  baseUrl: _kApiBase,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
  contentType: 'application/json',
);

/// Dio không có auth header — dùng cho auth endpoints (login, refresh, logout)
final authDioProvider = Provider<Dio>((ref) {
  return Dio(_baseOptions);
});

/// Dio có Bearer token — dùng cho mọi endpoint cần xác thực
final apiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // authProvider dùng authDioProvider nên không bị circular dependency
        final token = ref.read(authProvider).accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 → token hết hạn → logout
        if (error.response?.statusCode == 401) {
          ref.read(authProvider.notifier).logout();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
