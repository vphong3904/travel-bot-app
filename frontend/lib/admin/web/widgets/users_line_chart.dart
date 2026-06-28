// lib/features/dashboard/widgets/users_line_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/dashboard_overview.dart';
import 'chart_card.dart';

class UsersLineChart extends StatelessWidget {
  final List<TimeSeriesPoint> data;
  const UsersLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const ChartCard(title: 'Người dùng mới', child: _EmptyState());
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.count.toDouble());
    }).toList();

    final maxY = data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    // interval ticks dọc: chia ~4 bậc
    final yInterval = (maxY / 4).ceilToDouble().clamp(1.0, double.infinity);

    return ChartCard(
      title: 'Người dùng mới',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
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
                  interval: (data.length / 5).ceilToDouble().clamp(1.0, double.infinity),
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= data.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('dd/M').format(data[idx].date),
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
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) {
                  final idx = s.x.toInt();
                  final label = idx >= 0 && idx < data.length
                      ? DateFormat('dd/MM').format(data[idx].date)
                      : '';
                  return LineTooltipItem(
                    '$label\n${s.y.toInt()} người',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: const Color(0xFF2563EB),
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: 0.15),
                      const Color(0xFF2563EB).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}