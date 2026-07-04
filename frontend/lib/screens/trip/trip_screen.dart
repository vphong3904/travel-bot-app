// lib/screens/trip/trip_screen.dart
// TripScreen — Tab "Chuyến đi" (hub cá nhân).
// Gộp 3 nội dung: Yêu thích • Chuyến đi đã lưu • Lịch sử chat.
// Mỗi tab tái sử dụng screen sẵn có ở chế độ embedded (không AppBar riêng).

import 'package:flutter/material.dart';

import '../../widgets/common_widgets.dart';
import '../services/favorites_screen.dart';
import '../services/saved_trips_screen.dart';
import '../chat/chat_history_screen.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: const Text('Chuyến đi của tôi',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Yêu thích'),
              Tab(text: 'Chuyến đi'),
              Tab(text: 'Lịch sử chat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FavoritesScreen(embedded: true),
            SavedTripsScreen(embedded: true),
            ChatHistoryScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}
