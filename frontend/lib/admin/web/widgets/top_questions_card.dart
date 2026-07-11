// lib/admin/web/widgets/top_questions_card.dart
// TP-004/TP-008 — Card "Câu hỏi hay hỏi" trên Dashboard: top câu hỏi user
// hỏi nhiều nhất trong period (GET /admin/analytics/top-questions).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/dashboard_provider.dart';
import 'chart_card.dart';

class TopQuestionsCard extends ConsumerWidget {
  final String period;
  const TopQuestionsCard({super.key, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(topQuestionsProvider(period));
    return ChartCard(
      title: 'Câu hỏi user hay hỏi',
      child: asyncItems.when(
        loading: () => const SizedBox(
            height: 120, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => SizedBox(
            height: 80,
            child: Center(
                child: Text('Không tải được dữ liệu',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)))),
        data: (items) {
          if (items.isEmpty) {
            return SizedBox(
                height: 80,
                child: Center(
                    child: Text('Chưa có câu hỏi nào trong kỳ này',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12))));
          }
          return Column(
            children: [
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < 3
                              ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: i < 3
                                    ? const Color(0xFF2563EB)
                                    : Colors.grey.shade600)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          items[i]['question']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${items[i]['count']} lần',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade700)),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
