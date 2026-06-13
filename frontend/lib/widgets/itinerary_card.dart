import 'package:flutter/material.dart';
import 'common_widgets.dart';

class ItineraryCard extends StatelessWidget {
  final Map<String, dynamic> itinerary;

  const ItineraryCard({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    final destination = itinerary['destination'] ?? 'Địa điểm chưa rõ';
    final duration = itinerary['duration'] ?? 'Thời gian chưa rõ';
    final group = itinerary['group'] ?? 'Nhóm chưa rõ';
    final budgetLow = itinerary['budget_low'] ?? 0;
    final budgetHigh = itinerary['budget_high'] ?? 0;
    final days = itinerary['days'] is List
        ? List<dynamic>.from(itinerary['days'])
        : <dynamic>[];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Lịch trình AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Điểm đến', value: destination),
          _InfoRow(label: 'Thời gian', value: duration),
          _InfoRow(label: 'Nhóm', value: group),
          if (budgetLow > 0 || budgetHigh > 0)
            _InfoRow(label: 'Ngân sách', value: '${formatCurrency(budgetLow)} - ${formatCurrency(budgetHigh)}'),
          if (days.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Gợi ý ngày', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark)),
            const SizedBox(height: 8),
            ...days.take(3).map((day) {
              final map = day as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${map['day'] ?? ''}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(map['title'] ?? '', style: const TextStyle(fontSize: 13))),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
