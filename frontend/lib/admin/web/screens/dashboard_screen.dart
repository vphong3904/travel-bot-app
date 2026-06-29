// lib/admin/web/screens/dashboard_screen.dart
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/data/dashboard_repository.dart';
import '../../shared/providers/dashboard_provider.dart';
import '../../shared/models/dashboard_overview.dart';
import '../widgets/kpi_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/users_line_chart.dart';
import '../widgets/messages_bar_chart.dart';
import '../widgets/top_destinations_chart.dart';
import '../widgets/intent_pie_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final overviewAsync = ref.watch(dashboardOverviewProvider(period));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header row
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tổng quan hệ thống PDTrip',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                PeriodSelector(
                  value: period,
                  onChanged: (p) =>
                      ref.read(selectedPeriodProvider.notifier).state = p,
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: overviewAsync.hasValue
                      ? () => _exportExcel(ref, period)
                      : null,
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Export Excel'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            overviewAsync.when(
              loading: () => const _DashboardSkeleton(),
              error: (e, _) => _ErrorView(message: e.toString()),
              data: (data) => _DashboardContent(data: data),
            ),
          ],
        ),
      );
  }

  Future<void> _exportExcel(WidgetRef ref, String period) async {
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final bytes = await repo.exportExcel(period);
      final blob = web.Blob(
        [Uint8List.fromList(bytes).toJS].toJS,
        web.BlobPropertyBag(
            type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      );
      final url = web.URL.createObjectURL(blob);
      web.HTMLAnchorElement()
        ..href = url
        ..download = 'dashboard_$period.xlsx'
        ..click();
      web.URL.revokeObjectURL(url);
    } catch (_) {
      // Export error — không bubble lên UI
    }
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardOverview data;
  const _DashboardContent({required this.data});

  static String _fmt(int n) => NumberFormat('#,###').format(n);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // KPI Cards — 4 cột desktop / 2 cột tablet
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 900 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: cols == 4 ? 2.2 : 1.8,
            children: [
              KpiCard(
                title: 'Tổng người dùng',
                value: _fmt(data.kpi.totalUsers),
                icon: Icons.people_outline,
                color: const Color(0xFF2563EB),
                subtitle: '+${_fmt(data.kpi.newUsersThisPeriod)} kỳ này',
              ),
              KpiCard(
                title: 'Chat Sessions',
                value: _fmt(data.kpi.totalChatSessions),
                icon: Icons.chat_bubble_outline,
                color: const Color(0xFF7C3AED),
              ),
              KpiCard(
                title: 'Tỉ lệ trả lời',
                value:
                    '${(data.kpi.answeredRate * 100).toStringAsFixed(1)}%',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF10B981),
              ),
              KpiCard(
                title: 'Chờ xử lý',
                value: _fmt(
                  data.kpi.pendingUnanswered + data.kpi.pendingFlagged,
                ),
                icon: Icons.warning_amber_outlined,
                color: const Color(0xFFF59E0B),
                subtitle:
                    '${data.kpi.pendingUnanswered} chưa trả lời · ${data.kpi.pendingFlagged} bị flag',
                isAlert: true,
              ),
            ],
          );
        }),
        const SizedBox(height: 16),

        // Charts 2×2
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 900;
          if (wide) {
            return Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: UsersLineChart(data: data.usersOverTime)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: TopDestinationsChart(
                              data: data.topDestinations)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child:
                              IntentPieChart(data: data.intentBreakdown)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: MessagesBarChart(
                              data: data.messagesOverTime)),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              UsersLineChart(data: data.usersOverTime),
              const SizedBox(height: 12),
              TopDestinationsChart(data: data.topDestinations),
              const SizedBox(height: 12),
              IntentPieChart(data: data.intentBreakdown),
              const SizedBox(height: 12),
              MessagesBarChart(data: data.messagesOverTime),
            ],
          );
        }),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text('Không thể tải dữ liệu',
                style: TextStyle(
                    fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(message,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: List.generate(4, (_) => _skeletonBox(height: null)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skeletonBox(height: 260)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonBox(height: 260)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skeletonBox(height: 260)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonBox(height: 260)),
          ],
        ),
      ],
    );
  }

  Widget _skeletonBox({double? height}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}