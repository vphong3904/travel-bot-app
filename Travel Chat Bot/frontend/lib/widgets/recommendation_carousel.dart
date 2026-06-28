import 'dart:async';

import 'package:flutter/material.dart';

import '../models/destination.dart';
import 'common_widgets.dart';

class RecommendationCarousel extends StatefulWidget {
  final List<Destination> destinations;

  const RecommendationCarousel({super.key, required this.destinations});

  @override
  State<RecommendationCarousel> createState() => _RecommendationCarouselState();
}

class _RecommendationCarouselState extends State<RecommendationCarousel> {
  final _controller = PageController(viewportFraction: 0.96);
  late final Timer _timer;
  int _activeIndex = 0;

  List<_CarouselItem> get _items {
    if (widget.destinations.isEmpty) {
      return [
        _CarouselItem(
          title: 'Khám phá những điểm đến mới',
          subtitle: 'Nhận gợi ý chuyến đi cá nhân hóa chỉ với 1 chạm.',
          gradient: const LinearGradient(colors: [AppColors.gradStart, AppColors.gradEnd]),
        ),
        _CarouselItem(
          title: 'Lên lịch thông minh',
          subtitle: 'AI đề xuất hành trình theo ngân sách và thời gian của bạn.',
          gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF34D399)]),
        ),
      ];
    }

    return widget.destinations.take(4).map((destination) {
      return _CarouselItem(
        title: destination.name,
        subtitle: '${destination.region} · ${destination.description}',
        gradient: const LinearGradient(colors: [AppColors.gradStart, AppColors.gradEnd]),
        imageUrl: destination.imageUrl,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _items.isEmpty) return;
      final nextPage = (_activeIndex + 1) % _items.length;
      _controller.animateToPage(nextPage, duration: const Duration(milliseconds: 550), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (index) {
              setState(() => _activeIndex = index);
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 12, right: index == items.length - 1 ? 0 : 0),
                child: _RecommendationCard(item: item),
              );
            },
          ),
          Positioned(
            left: 16,
            bottom: 12,
            child: Row(
              children: List.generate(
                items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _activeIndex == index ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _activeIndex == index ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselItem {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final LinearGradient gradient;

  _CarouselItem({
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.imageUrl,
  });
}

class _RecommendationCard extends StatelessWidget {
  final _CarouselItem item;

  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              Opacity(
                opacity: 0.16,
                child: Image.network(item.imageUrl!, fit: BoxFit.cover, loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox.shrink();
                }, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gợi ý hành trình', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(item.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('Chi tiết ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
