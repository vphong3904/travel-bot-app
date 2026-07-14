// lib/screens/trip_detail/trip_details_screen.dart
// Hiển thị chi tiết 1 lịch trình — nhận 1 trong 2 nguồn:
//   - `itinerary`: payload chat/draft chưa lưu (có thể có `ai_plan` đầy đủ)
//   - `savedTrip`: TripPlanOut thật từ GET /trips/{id} (items dạng phẳng,
//     cần gom lại theo day_number) — chuyến đã lưu, chỉ xem, không sửa/lưu.
// Dùng chung TripPlanView (widgets/trip_plan_view.dart) với AiPlannerScreen/
// chatbot_screen để nhìn nhất quán — trước đây màn này tự vẽ text thô,
// không ảnh, không giá, dữ liệu mẫu hardcode (Phú Quốc) khi thiếu itinerary.
import 'package:flutter/material.dart';
import '../../widgets/trip_plan_view.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? itinerary;
  final Map<String, dynamic>? savedTrip;

  const TripDetailsScreen({super.key, this.itinerary, this.savedTrip});

  /// Gom items phẳng (day_number/order_in_day) của TripPlanOut thành
  /// days[{day_number, items[]}] theo đúng shape TripPlanView cần.
  Map<String, dynamic> _planFromSavedTrip(Map<String, dynamic> trip) {
    final items = (trip['items'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final byDay = <int, List<Map<String, dynamic>>>{};
    Map<String, dynamic>? hotel;
    for (final it in items) {
      final day = (it['day_number'] as num?)?.toInt() ?? 1;
      byDay.putIfAbsent(day, () => []).add(it);
      if (hotel == null && it['type'] == 'hotel_checkin') {
        hotel = {
          'id': it['ref_id'],
          'name': (it['title'] ?? '').toString().replaceFirst('Nhận phòng ', ''),
          'image_url': it['image_url'],
          'address': it['notes'],
        };
      }
    }
    for (final list in byDay.values) {
      list.sort((a, b) =>
          ((a['order_in_day'] as num?) ?? 0).compareTo((b['order_in_day'] as num?) ?? 0));
    }
    final dayNumbers = byDay.keys.toList()..sort();
    final days = dayNumbers.map((n) => {'day_number': n, 'items': byDay[n]}).toList();

    return {
      'title': trip['title'],
      'destination_image': trip['destination_image'],
      'days_count': days.length,
      'travelers': trip['travelers'],
      'travel_type': trip['travel_type'],
      'budget': trip['budget'],
      'estimated_cost': trip['estimated_cost'],
      'hotel': hotel,
      'days': days,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> plan;
    if (savedTrip != null) {
      plan = _planFromSavedTrip(savedTrip!);
    } else if (itinerary?['ai_plan'] is Map) {
      plan = Map<String, dynamic>.from(itinerary!['ai_plan'] as Map);
    } else {
      // Itinerary cũ dạng RAG mẫu tĩnh (destination/duration/group/days:
      // [{day,title,activities}]) — không có ai_plan, dựng plan tối thiểu.
      final dest = itinerary?['destination']?.toString() ?? 'Chuyến đi';
      final rawDays = itinerary?['days'];
      final days = (rawDays is List ? rawDays : const [])
          .map((d) => Map<String, dynamic>.from(d as Map))
          .map((d) => {
                'day_number': d['day'] ?? d['day_no'] ?? 1,
                'items': ((d['activities'] as List?) ?? const [])
                    .map((a) => {'type': 'free', 'title': a.toString(), 'time_slot': null})
                    .toList(),
              })
          .toList();
      plan = {
        'title': 'Kế hoạch $dest',
        'days_count': days.length,
        'travelers': null,
        'travel_type': itinerary?['group'],
        'budget': itinerary?['budget_high'],
        'days': days,
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plan['title']?.toString() ?? 'Chi tiết chuyến đi',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [TripPlanView(plan: plan)],
      ),
    );
  }
}
