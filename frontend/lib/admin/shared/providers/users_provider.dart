// lib/admin/shared/providers/users_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/users_repository.dart';
import '../models/user_model.dart';

class UsersFilter {
  final String search;
  final String role;
  final int page;

  const UsersFilter({this.search = '', this.role = '', this.page = 1});

  UsersFilter copyWith({String? search, String? role, int? page}) => UsersFilter(
        search: search ?? this.search,
        role: role ?? this.role,
        page: page ?? this.page,
      );

  @override
  bool operator ==(Object other) =>
      other is UsersFilter &&
      search == other.search &&
      role == other.role &&
      page == other.page;

  @override
  int get hashCode => Object.hash(search, role, page);
}

final usersFilterProvider =
    StateProvider<UsersFilter>((ref) => const UsersFilter());

final usersListProvider = FutureProvider.autoDispose
    .family<({List<UserModel> items, int total}), UsersFilter>(
  (ref, filter) async {
    final repo = ref.watch(usersRepositoryProvider);
    return repo.listUsers(
      search: filter.search,
      role: filter.role,
      page: filter.page,
    );
  },
);

final userDetailProvider =
    FutureProvider.autoDispose.family<UserDetail, String>(
  (ref, userId) async {
    final repo = ref.watch(usersRepositoryProvider);
    return repo.getUserDetail(userId);
  },
);
