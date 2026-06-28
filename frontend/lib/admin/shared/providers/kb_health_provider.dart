// lib/admin/shared/providers/kb_health_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/kb_health_repository.dart';
import '../models/kb_health_models.dart';

final kbHealthProvider =
    FutureProvider.autoDispose<KbHealthResponse>((ref) async {
  final repo = ref.watch(kbHealthRepositoryProvider);
  ref.keepAlive();
  return repo.fetchHealth();
});
