// lib/admin/shared/data/users_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/dio_provider.dart';

class UsersRepository {
  final Dio _dio;
  UsersRepository(this._dio);

  Future<({List<UserModel> items, int total})> listUsers({
    String search = '',
    String role = '',
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/users',
      queryParameters: {
        if (search.isNotEmpty) 'q': search,
        if (role.isNotEmpty) 'role': role,
        if (isActive != null) 'is_active': isActive,
        'page': page,
        'limit': pageSize,
      },
    );
    final data = res.data!;
    return (
      items: (data['items'] as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
    );
  }

  Future<UserDetail> getUserDetail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/admin/users/$id');
    return UserDetail.fromJson(res.data!);
  }

  Future<void> updateUser(
    String id, {
    bool? isActive,
    String? fullName,
  }) async {
    await _dio.patch<void>(
      '/admin/users/$id',
      data: {
        if (isActive != null) 'is_active': isActive,
        if (fullName != null) 'full_name': fullName,
      },
    );
  }

  Future<void> changeRole(String id, String newRole) async {
    await _dio.patch<void>(
      '/admin/users/$id/role',
      data: {'role': newRole},
    );
  }

  Future<void> createUser({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String role = 'user',
  }) async {
    await _dio.post<void>(
      '/admin/users',
      data: {
        'username': username,
        'email': email,
        'password': password,
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        'role': role,
      },
    );
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete<void>('/admin/users/$id');
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(apiDioProvider));
});
