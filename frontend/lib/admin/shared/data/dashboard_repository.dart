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