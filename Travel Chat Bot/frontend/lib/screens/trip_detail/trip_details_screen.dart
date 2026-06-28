import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? itinerary;

  const TripDetailsScreen({super.key, this.itinerary});

  @override
  Widget build(BuildContext context) {
    final dest = itinerary?['destination'] ?? 'Phú Quốc';
    final duration = itinerary?['duration'] ?? '3 ngày 2 đêm';
    final group = itinerary?['group'] ?? 'gia đình';
    final rawDays = itinerary?['days'];
    final List<dynamic> days =
        rawDays is List ? rawDays : _defaultDays(dest);
    final budgetLow = itinerary?['budget_low'] ?? 4000000;
    final budgetHigh = itinerary?['budget_high'] ?? 10000000;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kế Hoạch $dest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          bottom: const TabBar(tabs: [Tab(text: 'Tổng quan'), Tab(text: 'Lộ trình chi tiết')]),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OverviewTile(icon: Icons.flight_land, label: 'Điểm đến', value: dest),
                  _OverviewTile(icon: Icons.schedule, label: 'Thời gian', value: duration),
                  _OverviewTile(icon: Icons.groups, label: 'Nhóm', value: group),
                  _OverviewTile(icon: Icons.attach_money, label: 'Ngân sách', value: '${formatCurrency(budgetLow)} - ${formatCurrency(budgetHigh)}'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(child: Text('Lịch trình được tạo bởi AI + RAG từ Knowledge Base du lịch', style: TextStyle(fontSize: 13, color: AppColors.dark))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final day = days[i] as Map<String, dynamic>;
                final activities = (day['activities'] as List?)?.cast<String>() ?? [];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: Text(day['title'] ?? 'Ngày ${day['day']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      ...activities.map((a) => ListTile(
                            dense: true,
                            leading: CircleAvatar(radius: 14, backgroundColor: AppColors.secondary.withValues(alpha: 0.15), child: Icon(Icons.check, size: 14, color: AppColors.secondary)),
                            title: Text(a, style: const TextStyle(fontSize: 14)),
                          )),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _defaultDays(String dest) => [
        {'day': 1, 'title': 'Ngày 1: Khởi hành', 'activities': ['Di chuyển đến $dest', 'Check-in & nghỉ ngơi']},
        {'day': 2, 'title': 'Ngày 2: Khám phá', 'activities': ['Tham quan điểm nổi bật', 'Ẩm thực địa phương']},
        {'day': 3, 'title': 'Ngày 3: Kết thúc', 'activities': ['Mua quà lưu niệm', 'Trả phòng & về']},
      ];
}

class _OverviewTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: AppColors.muted)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
