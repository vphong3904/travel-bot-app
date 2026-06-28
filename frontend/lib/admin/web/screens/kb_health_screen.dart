// lib/admin/web/screens/kb_health_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/kb_health_models.dart';
import '../../shared/providers/kb_health_provider.dart';

const _ctLabels = {
  'destinations': 'Địa điểm',
  'hotels': 'K.Sạn',
  'restaurants': 'Nhà hàng',
  'foods': 'Ẩm thực',
  'transport': 'Di chuyển',
  'tours': 'Tour',
  'events': 'Sự kiện',
  'shopping': 'Mua sắm',
  'itineraries': 'Lịch trình',
  'experiences': 'Trải nghiệm',
  'faq': 'FAQ',
};

class KbHealthScreen extends ConsumerStatefulWidget {
  const KbHealthScreen({super.key});

  @override
  ConsumerState<KbHealthScreen> createState() => _KbHealthScreenState();
}

class _KbHealthScreenState extends ConsumerState<KbHealthScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(kbHealthProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthAsync = ref.watch(kbHealthProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'KB Health Checker',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Trạng thái dữ liệu knowledge-base/ theo từng thành phố',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(kbHealthProvider),
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: healthAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCards(summary: data.summary),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _legendItem(
                          Colors.green.shade500, 'Có dữ liệu'),
                      const SizedBox(width: 16),
                      _legendItem(
                          Colors.red.shade400, 'Không có / rỗng'),
                      const SizedBox(width: 16),
                      _legendItem(
                          Colors.grey.shade200, 'File rỗng (<200B)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _HeatmapTable(data: data)),
                  const SizedBox(height: 16),
                  _WorstCitiesList(cities: data.cities),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: Colors.grey.shade300, width: 0.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}

class _SummaryCards extends StatelessWidget {
  final KbHealthSummary summary;
  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _card('Tổng thành phố', '${summary.totalCities}',
            Colors.black87),
        const SizedBox(width: 12),
        _card('Đầy đủ dữ liệu', '${summary.completeCities}',
            Colors.green.shade700),
        const SizedBox(width: 12),
        _card('Chưa có dữ liệu', '${summary.emptyCities}',
            Colors.red.shade700),
        const SizedBox(width: 12),
        _card(
          'Độ phủ TB',
          '${summary.avgCompletenessPct}%',
          summary.avgCompletenessPct > 70
              ? Colors.green.shade700
              : Colors.amber.shade700,
        ),
      ],
    );
  }

  Widget _card(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapTable extends StatelessWidget {
  final KbHealthResponse data;
  const _HeatmapTable({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
                Colors.grey.shade50),
            columnSpacing: 8,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 36,
            columns: [
              const DataColumn(
                label: SizedBox(
                  width: 160,
                  child: Text(
                    'Thành phố',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ...data.contentTypes.map(
                (ct) => DataColumn(
                  label: SizedBox(
                    width: 70,
                    child: Text(
                      _ctLabels[ct] ?? ct,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const DataColumn(
                  label: SizedBox(
                      width: 40, child: Text('%'))),
            ],
            rows: data.cities
                .map((city) => DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 160,
                            child: Text(
                              city.citySlug,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        ...data.contentTypes.map((ct) {
                          final file = city.files[ct];
                          final hasData =
                              file?.hasData ?? false;
                          final existsEmpty =
                              (file?.exists ?? false) && !hasData;

                          final Color cellColor;
                          final Color textColor;
                          final String cellText;
                          if (hasData) {
                            cellColor = Colors.green.shade500;
                            textColor = Colors.white;
                            cellText = '✓';
                          } else if (existsEmpty) {
                            cellColor = Colors.grey.shade200;
                            textColor = Colors.grey.shade500;
                            cellText = '~';
                          } else {
                            cellColor = Colors.red.shade400;
                            textColor = Colors.white;
                            cellText = '✕';
                          }

                          return DataCell(
                            GestureDetector(
                              onTap: hasData
                                  ? null
                                  : () => context.go(
                                      '/content/$ct?city_slug=${city.citySlug}'),
                              child: Tooltip(
                                message: hasData
                                    ? 'Có dữ liệu (${file?.sizeBytes ?? 0} bytes)'
                                    : 'Thiếu dữ liệu — click để tạo',
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cellText,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        DataCell(
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${city.completenessPct}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: city.completenessPct == 100
                                    ? Colors.green.shade700
                                    : city.completenessPct > 50
                                        ? Colors.amber.shade700
                                        : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _WorstCitiesList extends StatelessWidget {
  final List<KbHealthCity> cities;
  const _WorstCitiesList({required this.cities});

  @override
  Widget build(BuildContext context) {
    final worst = [...cities]
      ..sort(
          (a, b) => a.completenessPct.compareTo(b.completenessPct));
    final top5 = worst.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5 thành phố thiếu dữ liệu nhiều nhất',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...top5.map((city) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      city.citySlug,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: city.completenessPct / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red.shade400),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${city.completenessPct}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => context.go(
                        '/content/destinations?city_slug=${city.citySlug}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      textStyle:
                          const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Nhập liệu →'),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
