// lib/features/dashboard/widgets/intent_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../shared/models/dashboard_overview.dart';
import 'chart_card.dart';

const _kColors = [
  Color(0xFF2563EB),
  Color(0xFF7C3AED),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFFEF4444),
  Color(0xFF6B7280),
];

class IntentPieChart extends StatefulWidget {
  final List<IntentItem> data;
  const IntentPieChart({super.key, required this.data});

  @override
  State<IntentPieChart> createState() => _IntentPieChartState();
}

class _IntentPieChartState extends State<IntentPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const ChartCard(
        title: 'Phân loại Intent',
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    final total = widget.data.fold<int>(0, (s, e) => s + e.count);

    return ChartCard(
      title: 'Phân loại Intent',
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            // Pie chart
            Expanded(
              flex: 5,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final idx = response?.touchedSection?.touchedSectionIndex;
                      setState(() => _touchedIndex = idx);
                    },
                  ),
                  centerSpaceRadius: 36,
                  sectionsSpace: 2,
                  sections: widget.data.asMap().entries.map((entry) {
                    final isTouched = entry.key == _touchedIndex;
                    final pct = total > 0 ? entry.value.count / total * 100 : 0;
                    return PieChartSectionData(
                      color: _kColors[entry.key % _kColors.length],
                      value: entry.value.count.toDouble(),
                      title: isTouched
                          ? '${pct.toStringAsFixed(0)}%'
                          : pct >= 10
                              ? '${pct.toStringAsFixed(0)}%'
                              : '',
                      radius: isTouched ? 78 : 68,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Legend
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.data.asMap().entries.map((entry) {
                  final isHighlighted = entry.key == _touchedIndex;
                  final pct = total > 0 ? entry.value.count / total * 100 : 0;
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _touchedIndex = _touchedIndex == entry.key ? null : entry.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: isHighlighted ? 12 : 10,
                            height: isHighlighted ? 12 : 10,
                            decoration: BoxDecoration(
                              color: _kColors[entry.key % _kColors.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.value.displayLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isHighlighted
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}