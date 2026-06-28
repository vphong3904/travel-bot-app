import 'package:flutter/material.dart';

import '../../models/service.dart';
import '../../widgets/common_widgets.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.service, required this.onTap});

  String get typeLabel {
    switch (service.type) {
      case 'hotel':
        return 'Khách sạn';
      case 'tour':
        return 'Tour du lịch';
      case 'ticket':
        return 'Vé & Bảo tàng';
      default:
        return service.type;
    }
  }

  IconData get typeIcon {
    switch (service.type) {
      case 'hotel':
        return Icons.hotel;
      case 'tour':
        return Icons.flight_takeoff;
      case 'ticket':
        return Icons.confirmation_number;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  service.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    child: const Center(child: Icon(Icons.image_outlined, size: 42, color: AppColors.primary)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(typeIcon, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(typeLabel, style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      if (service.rating > 0)
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${service.rating.toStringAsFixed(1)} (${service.reviews})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(service.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.dark), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(service.description, style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Expanded(child: Text(service.location, style: TextStyle(fontSize: 12, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      Text('${formatCurrency(service.price.toInt())}/đêm', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
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
