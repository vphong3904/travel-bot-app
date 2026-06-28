// lib/admin/shared/providers/rag_monitoring_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rag_monitoring_repository.dart';
import '../models/rag_monitoring_models.dart';

final ragDateRangeProvider =
    StateProvider<DateTimeRange?>((ref) => null);

final ragOverviewProvider =
    FutureProvider.autoDispose<RagOverview>((ref) async {
  final range = ref.watch(ragDateRangeProvider);
  final repo = ref.watch(ragMonitoringRepositoryProvider);
  return repo.fetchOverview(from: range?.start, to: range?.end);
});

final ragLatencyProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
        (ref) async {
  return ref.watch(ragMonitoringRepositoryProvider).fetchLatency();
});

final ragErrorsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
        (ref) async {
  return ref.watch(ragMonitoringRepositoryProvider).fetchErrors();
});
