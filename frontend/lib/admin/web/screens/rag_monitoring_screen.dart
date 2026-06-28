// lib/admin/web/screens/rag_monitoring_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/providers/rag_monitoring_provider.dart';
import '../widgets/rag_kpi_card.dart';
import '../widgets/confidence_trend_chart.dart';

class RagMonitoringScreen extends ConsumerStatefulWidget {
  const RagMonitoringScreen({super.key});

  @override
  ConsumerState<RagMonitoringScreen> createState() =>
      _RagMonitoringScreenState();
}

class _RagMonitoringScreenState
    extends ConsumerState<RagMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI / RAG Monitoring',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Chất lượng retrieval và latency theo thời gian',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: now,
                    initialDateRange:
                        ref.read(ragDateRangeProvider) ??
                            DateTimeRange(
                              start: now.subtract(
                                  const Duration(days: 30)),
                              end: now,
                            ),
                  );
                  if (range != null) {
                    ref
                        .read(ragDateRangeProvider.notifier)
                        .state = range;
                  }
                },
                icon: const Icon(Icons.date_range, size: 16),
                label: const Text('Chọn thời gian'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Latency'),
              Tab(text: 'Retrieval'),
              Tab(text: 'Errors'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _OverviewTab(),
                _LatencyTab(),
                _RetrievalTab(),
                _ErrorsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(ragOverviewProvider);
    return overviewAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (data) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RagKpiCard(
                    label: 'Confidence TB',
                    value: data.avgConfidenceScore
                        .toStringAsFixed(2),
                    color: data.avgConfidenceScore > 0.7
                        ? Colors.green.shade700
                        : data.avgConfidenceScore > 0.5
                            ? Colors.amber.shade700
                            : Colors.red.shade700,
                    icon: Icons.psychology_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RagKpiCard(
                    label: 'Cache Hit Rate',
                    value:
                        '${((data.cacheHitRate['exact'] ?? 0) + (data.cacheHitRate['semantic'] ?? 0)).toStringAsFixed(1)}%',
                    color: Colors.blue.shade700,
                    icon: Icons.cached,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RagKpiCard(
                    label: 'Hallucination Rate',
                    value:
                        '${data.hallucinationRate.toStringAsFixed(1)}%',
                    color: data.hallucinationRate < 5
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    icon: Icons.warning_amber_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RagKpiCard(
                    label: 'Avg Latency',
                    value:
                        '${(data.avgSearchMs + data.avgLlmMs).toStringAsFixed(0)}ms',
                    color: Colors.purple.shade700,
                    icon: Icons.timer_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Confidence Score theo thời gian',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ConfidenceTrendChart(
                  dataPoints: data.confidenceOverTime),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatencyTab extends ConsumerWidget {
  const _LatencyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latencyAsync = ref.watch(ragLatencyProvider);
    return latencyAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(
              child: Text('Chưa có dữ liệu latency'));
        }
        final searchSpots = rows.asMap().entries
            .map((e) => FlSpot(e.key.toDouble(),
                (e.value['avg_search_ms'] as num).toDouble()))
            .toList();
        final llmSpots = rows.asMap().entries
            .map((e) => FlSpot(e.key.toDouble(),
                (e.value['avg_llm_ms'] as num).toDouble()))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search ms vs LLM ms theo giờ',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: LineChart(LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: searchSpots,
                    color: Colors.blue,
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: llmSpots,
                    color: Colors.orange,
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: true),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              )),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _legendDot(Colors.blue, 'Search ms'),
                const SizedBox(width: 16),
                _legendDot(Colors.orange, 'LLM ms'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _legendDot(Color c, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}

class _RetrievalTab extends ConsumerWidget {
  const _RetrievalTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(ragOverviewProvider);
    return overviewAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (data) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Method Breakdown',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: data.searchMethodBreakdown.isEmpty
                      ? const Center(
                          child: Text('Chưa có dữ liệu'))
                      : PieChart(PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: data.searchMethodBreakdown[
                                      'qdrant'] ??
                                  0,
                              title: 'Qdrant',
                              color: Colors.blue.shade400,
                            ),
                            PieChartSectionData(
                              value: data.searchMethodBreakdown[
                                      'fts'] ??
                                  0,
                              title: 'FTS',
                              color: Colors.green.shade400,
                            ),
                            PieChartSectionData(
                              value: data.searchMethodBreakdown[
                                      'hybrid'] ??
                                  0,
                              title: 'Hybrid',
                              color: Colors.purple.shade400,
                            ),
                            PieChartSectionData(
                              value: data.searchMethodBreakdown[
                                      'no_results'] ??
                                  0,
                              title: 'No Results',
                              color: Colors.red.shade400,
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        )),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân phối Confidence Score',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: _ConfidenceHistogram(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceHistogram extends StatelessWidget {
  const _ConfidenceHistogram();

  @override
  Widget build(BuildContext context) {
    final buckets = [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(toY: 5, color: Colors.red.shade300)
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(toY: 8, color: Colors.orange.shade300)
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(toY: 15, color: Colors.amber.shade300)
      ]),
      BarChartGroupData(x: 3, barRods: [
        BarChartRodData(toY: 22, color: Colors.yellow.shade600)
      ]),
      BarChartGroupData(x: 4, barRods: [
        BarChartRodData(toY: 30, color: Colors.green.shade300)
      ]),
    ];

    return BarChart(BarChartData(
      barGroups: buckets,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final labels = [
                '0-0.2',
                '0.2-0.4',
                '0.4-0.6',
                '0.6-0.8',
                '0.8-1.0'
              ];
              final i = v.toInt();
              return i < labels.length
                  ? Text(labels[i],
                      style: const TextStyle(fontSize: 9))
                  : const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true, reservedSize: 30),
        ),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
    ));
  }
}

class _ErrorsTab extends ConsumerWidget {
  const _ErrorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorsAsync = ref.watch(ragErrorsProvider);
    return errorsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (errors) {
        if (errors.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 48, color: Colors.green),
                SizedBox(height: 8),
                Text('Không có lỗi nào',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
                Colors.grey.shade50),
            columns: const [
              DataColumn(label: Text('Thời gian')),
              DataColumn(label: Text('Loại lỗi')),
              DataColumn(label: Text('Message')),
            ],
            rows: errors
                .map((e) => DataRow(cells: [
                      DataCell(Text(
                          e['timestamp'] as String? ?? '—',
                          style:
                              const TextStyle(fontSize: 12))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                        child: Text(
                          e['error_type'] as String? ?? '—',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade700),
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 400,
                        child: Text(
                          e['message'] as String? ?? '—',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}
