// lib/widgets/trip_plan_view.dart
// Widget hiển thị 1 lịch trình AI đầy đủ (ảnh + khách sạn + timeline theo
// buổi + chi phí) — DÙNG CHUNG cho AiPlannerScreen (draft chưa lưu),
// chatbot_screen (lịch trình AI trả về trong chat) và TripDetailsScreen
// (chuyến đi đã lưu, xem lại). Trước đây mỗi nơi tự vẽ 1 kiểu (bare text ở
// ItineraryCard/TripDetailsScreen, chi tiết đầy đủ chỉ ở AiPlannerScreen) —
// gộp lại 1 chỗ để mọi nơi nhìn nhất quán và đẹp như nhau.
//
// `plan` nhận đúng shape từ backend (`plan` dict của build_plan / `ai_plan`
// trong itinerary payload của chat): title, destination_image, days_count,
// travelers, travel_type, budget, estimated_cost, budget_warning, summary,
// hotel{..., image_url}, days[{day_number, items[{time_slot, type, ref_id,
// title, description, estimated_cost, notes, image_url, address}]}],
// alternatives{hotels, restaurants, locations}.
//
// onSwapHotel/onSwapItem = null → ẩn nút đổi (dùng khi xem chuyến đã lưu,
// không còn alternatives để đổi nữa).
import 'package:flutter/material.dart';
import 'common_widgets.dart';

const _slotLabels = <String, String>{
  'morning': 'Sáng',
  'lunch': 'Trưa',
  'afternoon': 'Chiều',
  'evening': 'Tối',
};

const _slotColors = <String, Color>{
  'morning': Color(0xFFF59E0B),
  'lunch': Color(0xFF10B981),
  'afternoon': Color(0xFF3B82F6),
  'evening': Color(0xFF8B5CF6),
};

const _travelTypeLabels = <String, String>{
  'solo': 'Một mình',
  'couple': 'Cặp đôi',
  'family': 'Gia đình',
  'group': 'Nhóm bạn',
};

String _fmtVnd(num? v) {
  if (v == null || v <= 0) return '';
  final s = v.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${buf}đ';
}

class TripPlanView extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback? onSwapHotel;
  final void Function(Map item)? onSwapItem;

  const TripPlanView({
    super.key,
    required this.plan,
    this.onSwapHotel,
    this.onSwapItem,
  });

  @override
  Widget build(BuildContext context) {
    final days = (plan['days'] as List? ?? []);
    final hotel = plan['hotel'] as Map?;
    final destImage = plan['destination_image']?.toString();
    final travelType = plan['travel_type']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (destImage != null && destImage.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                destImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(plan['title']?.toString() ?? 'Lịch trình',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
        const SizedBox(height: 6),
        Wrap(spacing: 12, runSpacing: 4, children: [
          _metaChip(Icons.calendar_today_outlined, '${plan['days_count']} ngày'),
          if (plan['travelers'] != null)
            _metaChip(
              Icons.group_outlined,
              '${plan['travelers']} người'
              '${travelType != null && _travelTypeLabels.containsKey(travelType) ? " · ${_travelTypeLabels[travelType]}" : ""}',
            ),
          if (plan['budget'] != null)
            _metaChip(Icons.account_balance_wallet_outlined,
                'NS ${_fmtVnd(plan['budget'] as num?)}'),
          if (plan['estimated_cost'] != null)
            _metaChip(Icons.payments_outlined,
                'Ước tính ${_fmtVnd(plan['estimated_cost'] as num?)}'),
        ]),
        if (plan['summary'] != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(plan['summary'].toString(),
                style: const TextStyle(fontSize: 13, color: AppColors.dark, height: 1.5)),
          ),
        ],
        if (plan['budget_warning'] != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(plan['budget_warning'].toString(),
                      style: const TextStyle(fontSize: 12, color: AppColors.error))),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        if (hotel != null) _hotelCard(Map<String, dynamic>.from(hotel)),
        const SizedBox(height: 8),
        ...days.map((d) => _dayCard(context, Map<String, dynamic>.from(d as Map))),
      ],
    );
  }

  Widget _metaChip(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        ],
      );

  Widget _thumb(String? url, IconData fallbackIcon, {double size = 48}) {
    if (url == null || url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(fallbackIcon, color: AppColors.secondary, size: size * 0.45),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(fallbackIcon, color: AppColors.secondary, size: size * 0.45),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Center(
            child: Icon(Icons.landscape_outlined, size: 40, color: AppColors.primary)),
      );

  Widget _hotelCard(Map<String, dynamic> h) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(children: [
          _thumb(h['image_url']?.toString(), Icons.hotel_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h['name']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(
                [
                  if (h['stars'] != null) '${h['stars']}★',
                  if (h['price_per_night'] != null)
                    '${_fmtVnd(h['price_per_night'] as num?)}/đêm',
                  if (h['rating'] != null) '${h['rating']} điểm',
                ].join(' · '),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ]),
          ),
          if (onSwapHotel != null) TextButton(onPressed: onSwapHotel, child: const Text('Đổi')),
        ]),
      );

  Widget _dayCard(BuildContext context, Map<String, dynamic> d) {
    final items = (d['items'] as List? ?? []);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ngày ${d['day_number']}',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 10),
        ...items.map((raw) {
          final it = Map<String, dynamic>.from(raw as Map);
          final canSwap = onSwapItem != null &&
              (it['type'] == 'location' || it['type'] == 'restaurant');
          final dotColor = _slotColors[it['time_slot']] ?? AppColors.muted;
          final icon = switch (it['type']) {
            'hotel_checkin' => Icons.hotel_outlined,
            'restaurant' => Icons.restaurant_outlined,
            'location' => Icons.place_outlined,
            _ => Icons.wb_sunny_outlined,
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Timeline: chấm màu theo buổi + nhãn giờ
              SizedBox(
                width: 52,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(_slotLabels[it['time_slot']] ?? '',
                          style: TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.bold, color: dotColor)),
                    ),
                  ]),
                  if (it['start_time'] != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 2),
                      child: Text(it['start_time'].toString(),
                          style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                    ),
                ]),
              ),
              _thumb(it['image_url']?.toString(), icon, size: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(it['title']?.toString() ?? '',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  if (it['notes'] != null && it['notes'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(it['notes'].toString(),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                    ),
                  if (it['estimated_cost'] != null && (it['estimated_cost'] as num) > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Vé ~${_fmtVnd(it['estimated_cost'] as num?)}/người',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.primary)),
                    ),
                ]),
              ),
              if (canSwap)
                InkWell(
                  onTap: () => onSwapItem!(it),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.swap_horiz, size: 18, color: AppColors.muted),
                  ),
                ),
            ]),
          );
        }),
      ]),
    );
  }
}
