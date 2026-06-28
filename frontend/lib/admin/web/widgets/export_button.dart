// lib/admin/web/widgets/export_button.dart
import 'dart:js_interop';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;
import '../../shared/providers/dio_provider.dart';

class ExportButton extends ConsumerStatefulWidget {
  final String report;
  final String period;

  const ExportButton({
    super.key,
    this.report = 'overview',
    this.period = 'month',
  });

  @override
  ConsumerState<ExportButton> createState() =>
      _ExportButtonState();
}

class _ExportButtonState
    extends ConsumerState<ExportButton> {
  bool _loading = false;

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      final dio = ref.read(apiDioProvider);
      final resp = await dio.get<List<dynamic>>(
        '/admin/stats/export',
        queryParameters: {
          'format': 'excel',
          'report': widget.report,
          'period': widget.period,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes =
          (resp.data ?? []).map((e) => e as int).toList();
      final jsArray = bytes
          .map((b) => b.toJS)
          .toList()
          .toJS;
      final blob = web.Blob(
        jsArray,
        web.BlobPropertyBag(
          type:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );
      final url = web.URL.createObjectURL(blob);
      (web.document.createElement('a')
              as web.HTMLAnchorElement)
        ..href = url
        ..setAttribute(
          'download',
          'pdtrip_${widget.report}_${widget.period}.xlsx',
        )
        ..click();
      web.URL.revokeObjectURL(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã tải xuống file Excel')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi export: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _export,
      icon: _loading
          ? const SizedBox(
              width: 14,
              height: 14,
              child:
                  CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.download, size: 16),
      label: Text(
          _loading ? 'Đang xuất...' : 'Export Excel'),
    );
  }
}
