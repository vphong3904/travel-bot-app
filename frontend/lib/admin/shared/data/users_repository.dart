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
        if (search.isNotEmpty) 'search': search,
        if (role.isNotEmpty) 'role': role,
        if (isActive != null) 'is_active': isActive,
        'page': page,
        'page_size': pageSize,
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
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(apiDioProvider));
});
