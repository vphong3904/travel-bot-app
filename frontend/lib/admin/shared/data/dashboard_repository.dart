import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_overview.dart';
import '../providers/dio_provider.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<DashboardOverview> getOverview(String period) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/stats/overview',
      queryParameters: {'period': period},
    );
    return DashboardOverview.fromJson(res.data!);
  }

  /// TP-004: Câu hỏi user hay hỏi nhất (đã lọc smalltalk).
  /// Backend nhận period day|week|month — period khác sẽ dùng week.
  Future<List<Map<String, dynamic>>> topQuestions(String period,
      {int limit = 10}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/analytics/top-questions',
      queryParameters: {'period': period, 'limit': limit},
    );
    return (res.data!['items'] as List).cast<Map<String, dynamic>>();
  }

  /// Trả về raw bytes của file .xlsx để trigger download trên web
  Future<List<int>> exportExcel(String period) async {
    final res = await _dio.get<List<int>>(
      '/admin/stats/export',
      queryParameters: {
        'format': 'excel',
        'report': 'overview',
        'period': period,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data!;
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiDioProvider));
});