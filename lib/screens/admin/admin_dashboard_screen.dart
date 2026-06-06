import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../widgets/common_widgets.dart';
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Quản trị hệ thống', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatCard(title: 'Người dùng', value: '${stats['total_users'] ?? 0}', icon: Icons.people, color: AppColors.primary),
                        const SizedBox(width: 12),
                        _StatCard(title: 'Hội thoại', value: '${stats['total_chats'] ?? 0}', icon: Icons.chat, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatCard(title: 'KB Entries', value: '${stats['total_kb_entries'] ?? 0}', icon: Icons.library_books, color: AppColors.success, fullWidth: true),
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'Thống kê hội thoại 7 ngày'),
                    const SizedBox(height: 12),
                    _DailyChart(data: (stats['daily_chats'] as List?) ?? []),
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'Phân bố Intent (NLP)'),
                    const SizedBox(height: 12),
                    _IntentChart(data: (stats['intent_distribution'] as List?) ?? []),
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'Câu hỏi phổ biến'),
                    const SizedBox(height: 8),
                    ...((stats['popular_questions'] as List?) ?? []).take(5).map((q) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Expanded(child: Text(q['query'] ?? '', style: const TextStyle(fontSize: 13))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text('${q['count']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'Điểm đến được quan tâm'),
                    const SizedBox(height: 8),
                    ...((stats['popular_destinations'] as List?) ?? []).map((d) => ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          leading: const Icon(Icons.place, color: AppColors.secondary),
                          title: Text(d['destination'] ?? ''),
                          trailing: Text('${d['count']} lượt', style: TextStyle(color: AppColors.muted)),
                        )),
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'Quản lý'),
                    const SizedBox(height: 12),
                    _AdminMenuItem(icon: Icons.library_books, title: 'Knowledge Base', subtitle: 'Quản lý dữ liệu du lịch', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KBManagementScreen()))),
                    _AdminMenuItem(icon: Icons.people, title: 'Người dùng', subtitle: 'Quản lý tài khoản', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()))),
                    _AdminMenuItem(icon: Icons.history, title: 'Log hội thoại', subtitle: 'Xem lịch sử chatbot', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatLogsScreen()))),
                  ],
                ),
              ),
            ),
    );
  }
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
    return fullWidth ? card : Expanded(child: card);
  }
}

class _DailyChart extends StatelessWidget {
  final List<dynamic> data;

  const _DailyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('Chưa có dữ liệu')));
    final maxY = data.map((d) => (d['count'] as num?)?.toDouble() ?? 0).reduce((a, b) => a > b ? a : b);
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
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
                  return Text(date.length >= 5 ? date.substring(5) : date, style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
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
    final colors = [AppColors.primary, AppColors.secondary, AppColors.success, Colors.purple];
    final total = data.fold<int>(0, (s, d) => s + ((d['count'] as num?)?.toInt() ?? 0));
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: List.generate(data.length, (i) {
                  final count = (data[i]['count'] as num?)?.toDouble() ?? 0;
                  return PieChartSectionData(value: count, title: '${(count / total * 100).toStringAsFixed(0)}%', color: colors[i % colors.length], radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold));
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
                    Text(intentLabel(e.value['intent'] ?? ''), style: const TextStyle(fontSize: 11)),
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

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuItem({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.muted)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
