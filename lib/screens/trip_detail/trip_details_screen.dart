import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? itinerary;

  const TripDetailsScreen({super.key, this.itinerary});

  @override
  Widget build(BuildContext context) {
    final dest = itinerary?['destination'] ?? 'Phú Quốc';
    final duration = itinerary?['duration'] ?? '3 ngày 2 đêm';
    final group = itinerary?['group'] ?? 'gia đình';
    final days = (itinerary?['days'] as List?) ?? _defaultDays(dest);
    final budgetLow = itinerary?['budget_low'] ?? 4000000;
    final budgetHigh = itinerary?['budget_high'] ?? 10000000;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: AppBackButton(iconColor: Colors.white, backgroundColor: Colors.white.withValues(alpha: 0.2)),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Kế Hoạch $dest', style: AppTheme.heading(size: 24, color: Colors.white)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Badge(text: duration),
                          _Badge(text: group),
                          _Badge(text: '${formatCurrency(budgetLow)} - ${formatCurrency(budgetHigh)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.primary,
                tabs: const [Tab(text: 'Tổng quan'), Tab(text: 'Lộ trình chi tiết')],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                children: [
                  AppInfoCard(icon: Icons.flight_land_rounded, label: 'Điểm đến', value: dest),
                  AppInfoCard(icon: Icons.schedule_rounded, label: 'Thời gian', value: duration),
                  AppInfoCard(icon: Icons.groups_rounded, label: 'Nhóm', value: group),
                  AppInfoCard(icon: Icons.payments_outlined, label: 'Ngân sách', value: '${formatCurrency(budgetLow)} - ${formatCurrency(budgetHigh)}'),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Lịch trình được tạo tự động bởi AI dựa trên Knowledge Base du lịch.',
                            style: AppTheme.body(size: 13, color: AppColors.primaryDark, weight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                itemCount: days.length,
                itemBuilder: (_, i) {
                  final day = days[i] as Map<String, dynamic>;
                  final activities = (day['activities'] as List?)?.cast<String>() ?? [];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: Text(day['title'] ?? 'Ngày ${day['day']}', style: AppTheme.heading(size: 15, color: AppColors.primary)),
                        ),
                        ...activities.map((a) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.check_rounded, size: 14, color: AppColors.accent),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(child: Text(a, style: AppTheme.body(size: 14, color: AppColors.mid))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
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

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: AppTheme.body(size: 12, color: Colors.white, weight: FontWeight.w600)),
    );
  }
}
