import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/network_image_widget.dart';
import '../chat/chatbot_screen.dart';

class DestinationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final name = destination['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: AppBackButton(
                iconColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(url: destination['image_url'], fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTheme.heading(size: 32, color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(destination['region'] ?? '', style: AppTheme.body(size: 14, color: Colors.white.withValues(alpha: 0.9))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(destination['description'] ?? '', style: AppTheme.body(size: 14, color: const Color(0xFF475569))),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                AppInfoCard(icon: Icons.wb_sunny_outlined, label: 'Thời tiết', value: destination['weather'] ?? ''),
                AppInfoCard(icon: Icons.calendar_month_outlined, label: 'Mùa lý tưởng', value: destination['best_season'] ?? ''),
                AppInfoCard(icon: Icons.restaurant_outlined, label: 'Ẩm thực', value: destination['cuisine'] ?? ''),
                AppInfoCard(icon: Icons.star_outline_rounded, label: 'Điểm nổi bật', value: destination['highlights'] ?? ''),
                AppInfoCard(
                  icon: Icons.payments_outlined,
                  label: 'Chi phí tham khảo',
                  value: '${formatCurrency(destination['budget_low'] ?? 0)} - ${formatCurrency(destination['budget_high'] ?? 0)}/người',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: AppPrimaryButton(
                    label: 'Hỏi AI chi tiết về địa điểm này',
                    icon: Icons.support_agent_rounded,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatBotScreen(initialMessage: 'Cho tôi biết thông tin chi tiết về $name'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
