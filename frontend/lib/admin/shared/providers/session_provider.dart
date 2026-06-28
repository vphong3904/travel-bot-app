// lib/admin/shared/providers/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/session_repository.dart';
import '../models/user_session.dart';

final userSessionsProvider = FutureProvider.autoDispose
    .family<List<UserSession>, String>(
  (ref, userId) => ref
      .watch(sessionRepositoryProvider)
      .fetchSessions(userId),
);
