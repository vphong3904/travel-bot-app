// lib/admin/shared/data/system_backup_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dio_provider.dart';

class BackupInfo {
  final String filename;
  final int sizeBytes;
  final String createdAt;

  const BackupInfo({
    required this.filename,
    required this.sizeBytes,
    required this.createdAt,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> j) => BackupInfo(
        filename: j['filename'] as String,
        sizeBytes: j['size_bytes'] as int,
        createdAt: j['created_at'] as String,
      );
}

class SystemBackupRepository {
  final Dio _dio;
  SystemBackupRepository(this._dio);

  Future<BackupInfo> triggerBackup() async {
    final res =
        await _dio.post<Map<String, dynamic>>('/admin/system/backups');
    return BackupInfo.fromJson(res.data!);
  }

  Future<List<BackupInfo>> listBackups() async {
    final res =
        await _dio.get<Map<String, dynamic>>('/admin/system/backups');
    final items = (res.data!['items'] as List)
        .map((e) => BackupInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<List<int>> downloadBackup(String filename) async {
    final res = await _dio.get<List<int>>(
      '/admin/system/backups/$filename/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data!;
  }
}

final systemBackupRepositoryProvider =
    Provider<SystemBackupRepository>((ref) {
  return SystemBackupRepository(ref.watch(apiDioProvider));
});

final backupsListProvider = FutureProvider.autoDispose<List<BackupInfo>>(
  (ref) => ref.watch(systemBackupRepositoryProvider).listBackups(),
);
