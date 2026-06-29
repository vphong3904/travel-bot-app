// lib/features/dashboard/widgets/top_destinations_chart.dart
import 'package:flutter/material.dart';
import '../../shared/models/dashboard_overview.dart';
import 'chart_card.dart';

class TopDestinationsChart extends StatelessWidget {
  final List<TopDestinationItem> data;
  const TopDestinationsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const ChartCard(
        title: 'Địa điểm được hỏi nhiều nhất',
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    final top = data.take(8).toList();
    final maxVal = top.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    return ChartCard(
      title: 'Địa điểm được hỏi nhiều nhất',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: top.asMap().entries.map((entry) {
          final item = entry.value;
          final pct = maxVal > 0 ? item.count / maxVal : 0.0;
          final isTop = entry.key == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Rank badge
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isTop ? const Color(0xFF2563EB) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isTop ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tên địa điểm
                SizedBox(
                  width: 88,
                  child: Text(
                    item.destination,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isTop ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 18,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isTop ? const Color(0xFF10B981) : const Color(0xFF34D399),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Count
                SizedBox(
                  width: 36,
                  child: Text(
                    '${item.count}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}