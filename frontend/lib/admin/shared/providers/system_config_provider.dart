// lib/admin/shared/providers/system_config_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/system_config_repository.dart';
import '../models/system_config.dart';

final systemConfigProvider =
    FutureProvider.autoDispose<List<SystemConfig>>(
  (ref) =>
      ref.watch(systemConfigRepositoryProvider).fetchAll(),
);
