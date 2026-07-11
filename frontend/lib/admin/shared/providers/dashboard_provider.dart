// lib/features/dashboard/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_overview.dart';

/// Period được chọn — 'day' | 'week' | 'month' | 'quarter' | 'year'
final selectedPeriodProvider = StateProvider<String>((ref) => 'month');

/// Overview data — auto-dispose + family theo period
/// Thay đổi period tự invalidate và fetch lại
final dashboardOverviewProvider =
    FutureProvider.autoDispose.family<DashboardOverview, String>(
  (ref, period) async {
    final repo = ref.watch(dashboardRepositoryProvider);
    return repo.getOverview(period);
  },
);

/// TP-004: Câu hỏi user hay hỏi nhất theo period
final topQuestionsProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, period) async {
    final repo = ref.watch(dashboardRepositoryProvider);
    return repo.topQuestions(period);
  },
);