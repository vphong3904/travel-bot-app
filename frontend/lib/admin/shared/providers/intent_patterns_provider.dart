// lib/admin/shared/providers/intent_patterns_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/intent_patterns_repository.dart';
import '../models/intent_patterns_models.dart';

final intentPatternsProvider =
    FutureProvider.autoDispose<List<IntentPattern>>((ref) async {
  return ref
      .watch(intentPatternsRepositoryProvider)
      .fetchAll();
});

final selectedIntentProvider = StateProvider<String?>((ref) => null);

final intentTestResultProvider =
    StateProvider<IntentTestResult?>((ref) => null);
