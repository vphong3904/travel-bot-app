// lib/features/dashboard/widgets/messages_bar_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/dashboard_overview.dart';
import 'chart_card.dart';

class MessagesBarChart extends StatelessWidget {
  final List<TimeSeriesPoint> data;
  const MessagesBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const ChartCard(
        title: 'Tin nhắn theo ngày',
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    // Giới hạn hiển thị tối đa 30 điểm để bar không quá dày
    final display = data.length > 30 ? data.sublist(data.length - 30) : data;
    final maxY = display.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    final yInterval = (maxY / 4).ceilToDouble().clamp(1.0, double.infinity);

    return ChartCard(
      title: 'Tin nhắn theo ngày',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxY * 1.2,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.grey.shade100,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  interval: yInterval,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: (display.length / 5).ceilToDouble().clamp(1.0, double.infinity),
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= display.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('dd/M').format(display[idx].date),
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, rod, __) {
                  final idx = group.x;
                  final label = idx >= 0 && idx < display.length
                      ? DateFormat('dd/MM').format(display[idx].date)
                      : '';
                  return BarTooltipItem(
                    '$label\n${rod.toY.toInt()} tin nhắn',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            barGroups: display.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.count.toDouble(),
                    color: const Color(0xFF7C3AED),
                    width: display.length > 20 ? 6 : 12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}