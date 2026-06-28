// lib/admin/web/widgets/confidence_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ConfidenceTrendChart extends StatelessWidget {
  final List<({String date, double avgScore})> dataPoints;
  const ConfidenceTrendChart(
      {super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(
        child: Text('Chưa có dữ liệu',
            style: TextStyle(color: Colors.grey)),
      );
    }
    final spots = dataPoints.asMap().entries
        .map((e) =>
            FlSpot(e.key.toDouble(), e.value.avgScore))
        .toList();

    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.indigo.shade500,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.indigo.shade50,
          ),
        ),
      ],
      minY: 0,
      maxY: 1,
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 0.2,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 0.2,
            getTitlesWidget: (v, _) => Text(
              v.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= dataPoints.length) {
                return const SizedBox();
              }
              final date = dataPoints[i].date;
              return Text(
                date.length > 5 ? date.substring(5) : date,
                style: const TextStyle(fontSize: 9),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 0.7,
            color: Colors.green.shade300,
            strokeWidth: 1,
            dashArray: [4, 4],
            label: HorizontalLineLabel(
              show: true,
              labelResolver: (_) => '0.7',
              style: TextStyle(
                  color: Colors.green.shade600, fontSize: 10),
            ),
          ),
        ],
      ),
    ));
  }
}
