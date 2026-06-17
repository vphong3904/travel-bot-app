import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../models/destination.dart';
import '../chat/chatbot_screen.dart';

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final name = destination.name;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              background: Image.network(
                destination.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(destination.region, style: TextStyle(color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(destination.description, style: const TextStyle(height: 1.6)),
                  const SizedBox(height: 20),
                  _InfoCard(icon: Icons.wb_sunny_outlined, title: 'Thời tiết', content: destination.weather),
                  _InfoCard(icon: Icons.calendar_month, title: 'Mùa du lịch lý tưởng', content: destination.bestSeason),
                  _InfoCard(icon: Icons.restaurant, title: 'Ẩm thực', content: destination.cuisine),
                  _InfoCard(icon: Icons.star, title: 'Điểm nổi bật', content: destination.highlights),
                  _InfoCard(
                    icon: Icons.attach_money,
                    title: 'Chi phí tham khảo',
                    content: '${formatCurrency(destination.budgetLow)} - ${formatCurrency(destination.budgetHigh)}/người',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatBotScreen(initialMessage: 'Cho tôi biết thông tin chi tiết về $name'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.smart_toy),
                      label: const Text('Hỏi AI về địa điểm này'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(color: AppColors.muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
