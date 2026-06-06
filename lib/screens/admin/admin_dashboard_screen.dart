import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/web_layout.dart';
import 'kb_management_screen.dart';
import 'user_management_screen.dart';
import 'chat_logs_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> stats = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await AdminService.getStats();
    if (mounted) setState(() { stats = data; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return WebAdminShell(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Quản trị hệ thống', style: AppTheme.heading(size: 18)),
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load)],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatCard(title: 'Người dùng', value: '${stats['total_users'] ?? 0}', icon: Icons.people_outline_rounded, color: AppColors.primary),
                          const SizedBox(width: 12),
                          _StatCard(title: 'Hội thoại', value: '${stats['total_chats'] ?? 0}', icon: Icons.chat_bubble_outline_rounded, color: AppColors.accent),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatCard(title: 'KB Entries', value: '${stats['total_kb_entries'] ?? 0}', icon: Icons.library_books_outlined, color: AppColors.success, fullWidth: true),
                      const SizedBox(height: 24),
                      Text('Quản lý nhanh', style: AppTheme.heading(size: 18)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _QuickAction(icon: Icons.library_books_outlined, label: 'Knowledge Base', onTap: () => _open(const KBManagementScreen()))),
                          const SizedBox(width: 12),
                          Expanded(child: _QuickAction(icon: Icons.people_outline_rounded, label: 'Người dùng', onTap: () => _open(const UserManagementScreen()))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _QuickAction(icon: Icons.history_rounded, label: 'Log hội thoại chatbot', onTap: () => _open(const ChatLogsScreen()), fullWidth: true),
                      const SizedBox(height: 24),
                      SectionTitle(title: 'Thống kê hội thoại 7 ngày'),
                      const SizedBox(height: 12),
                      _DailyChart(data: (stats['daily_chats'] as List?) ?? []),
                      const SizedBox(height: 24),
                      SectionTitle(title: 'Phân bố Intent (NLP)'),
                      const SizedBox(height: 12),
                      _IntentChart(data: (stats['intent_distribution'] as List?) ?? []),
                      const SizedBox(height: 24),
                      SectionTitle(title: 'Câu hỏi phổ biến'),
                      const SizedBox(height: 8),
                      ...((stats['popular_questions'] as List?) ?? []).take(5).map((q) => _ListTile(
                            title: q['query'] ?? '',
                            trailing: '${q['count']}',
                          )),
                      const SizedBox(height: 24),
                      SectionTitle(title: 'Điểm đến được quan tâm'),
                      const SizedBox(height: 8),
                      ...((stats['popular_destinations'] as List?) ?? []).map((d) => _ListTile(
                            title: d['destination'] ?? '',
                            trailing: '${d['count']} lượt',
                            icon: Icons.place_outlined,
                          )),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _open(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.body(size: 12, color: AppColors.muted)),
              Text(value, style: AppTheme.heading(size: 22)),
            ],
          ),
        ],
      ),
    );
    return fullWidth ? card : Expanded(child: card);
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const _QuickAction({required this.icon, required this.label, required this.onTap, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: AppTheme.body(size: 14, weight: FontWeight.w600))),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final IconData icon;

  const _ListTile({required this.title, required this.trailing, this.icon = Icons.help_outline_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTheme.body(size: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(trailing, style: AppTheme.body(size: 12, color: AppColors.primary, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  final List<dynamic> data;

  const _DailyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(height: 100, child: Center(child: Text('Chưa có dữ liệu', style: AppTheme.body(color: AppColors.muted))));
    }
    final maxY = data.map((d) => (d['count'] as num?)?.toDouble() ?? 0).reduce((a, b) => a > b ? a : b);
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: BarChart(
        BarChartData(
          maxY: maxY + 2,
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: (data[i]['count'] as num?)?.toDouble() ?? 0, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  if (v.toInt() >= data.length) return const SizedBox();
                  final date = data[v.toInt()]['date']?.toString() ?? '';
                  return Text(date.length >= 5 ? date.substring(5) : date, style: AppTheme.body(size: 10, color: AppColors.muted));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: AppTheme.body(size: 10, color: AppColors.muted)))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _IntentChart extends StatelessWidget {
  final List<dynamic> data;

  const _IntentChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final colors = [AppColors.primary, AppColors.accent, AppColors.success, AppColors.gradEnd];
    final total = data.fold<int>(0, (s, d) => s + ((d['count'] as num?)?.toInt() ?? 0));
    if (total == 0) return const SizedBox();

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: List.generate(data.length, (i) {
                  final count = (data[i]['count'] as num?)?.toDouble() ?? 0;
                  return PieChartSectionData(
                    value: count,
                    title: '${(count / total * 100).toStringAsFixed(0)}%',
                    color: colors[i % colors.length],
                    radius: 40,
                    titleStyle: AppTheme.body(size: 10, color: Colors.white, weight: FontWeight.w700),
                  );
                }),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(intentLabel(e.value['intent'] ?? ''), style: AppTheme.body(size: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
