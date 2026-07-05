// lib/screens/detail/itinerary_detail_screen.dart
// Chi tiết 1 lịch trình gợi ý: thống kê chi phí (theo người) + lịch theo từng ngày.
import 'package:flutter/material.dart';

import '../../services/destination_service.dart';
import '../../widgets/common_widgets.dart';
import '../chat/chatbot_screen.dart';

// Các khoản chi phí hiển thị (key khớp cost.* từ backend).
const _kCostRows = [
  ('transport', 'Di chuyển', Icons.directions_bus_outlined, Color(0xFF2563EB)),
  ('accommodation', 'Lưu trú', Icons.hotel_outlined, Color(0xFF7C3AED)),
  ('food', 'Ăn uống', Icons.restaurant_outlined, Color(0xFFEA580C)),
  ('activities', 'Tham quan & vé', Icons.confirmation_number_outlined, Color(0xFF059669)),
  ('other', 'Khác / phát sinh', Icons.more_horiz, Color(0xFF64748B)),
];

// "3N2Đ" cho 3 ngày; "1 ngày" cho chuyến trong ngày.
String itineraryDurationLabel(int days) {
  final nights = days - 1;
  return nights > 0 ? '${days}N${nights}Đ' : '1 ngày';
}

class ItineraryDetailScreen extends StatefulWidget {
  final String id;
  const ItineraryDetailScreen({super.key, required this.id});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await DestinationRepository.fetchItinerary(widget.id);
    if (mounted) setState(() { _data = d; _loading = false; });
  }

  String _s(String k) => _data?[k]?.toString() ?? '';
  int _cost(String k) {
    final c = _data?['cost'];
    if (c is Map) {
      final v = c[k];
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('Lịch trình', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_data == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('Lịch trình', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, size: 44, color: AppColors.muted),
            const SizedBox(height: 10),
            const Text('Không tải được lịch trình', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () { setState(() => _loading = true); _load(); }, child: const Text('Thử lại')),
          ]),
        ),
      );
    }

    final days = (_data?['days'] as List?) ?? const [];
    final durationDays = int.tryParse('${_data?['duration_days']}') ?? 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Lịch trình gợi ý', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Header
          Text(_s('title'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _chip(Icons.event_outlined, itineraryDurationLabel(durationDays), AppColors.primary),
            _chip(Icons.group_outlined, _s('group_label'), AppColors.secondary),
            if (_s('destination_name').isNotEmpty)
              _chip(Icons.place_outlined, _s('destination_name'), AppColors.success),
          ]),
          if (_s('description').isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(_s('description'),
                style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.mid)),
          ],
          const SizedBox(height: 22),

          // Chi phí
          _buildCostCard(),
          const SizedBox(height: 24),

          // Lịch theo ngày
          const Text('Lịch trình chi tiết',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark)),
          const SizedBox(height: 6),
          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Chưa có lịch chi tiết cho gợi ý này.',
                  style: TextStyle(color: AppColors.muted)),
            )
          else
            ...days.whereType<Map>().map((d) => _buildDay(Map<String, dynamic>.from(d))),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChatBotScreen(
                  initialMessage: 'Tùy chỉnh giúp tôi lịch trình "${_s('title')}" '
                      '(${itineraryDurationLabel(durationDays)}, ${_s('group_label')})',
                ),
              )),
              icon: const Icon(Icons.smart_toy_outlined, size: 18),
              label: const Text('Hỏi AI tùy chỉnh lịch trình'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cost card ────────────────────────────────────────────────────────────────
  Widget _buildCostCard() {
    final total = _cost('total');
    final maxVal = _kCostRows
        .map((r) => _cost(r.$1))
        .fold<int>(1, (p, e) => e > p ? e : p);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.payments_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Thống kê chi phí',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.muted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('ước tính · /người',
                  style: TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 14),
          ..._kCostRows.map((r) => _costRow(r.$2, r.$3, r.$4, _cost(r.$1), maxVal)),
          const Divider(height: 24),
          Row(children: [
            const Text('Tổng cộng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
            const Spacer(),
            Text('${formatCurrency(total)}/người',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ]),
          const SizedBox(height: 4),
          Text('Ngân sách tham khảo: ${formatCurrency(int.tryParse('${_data?['budget_low']}') ?? 0)} '
              '– ${formatCurrency(int.tryParse('${_data?['budget_high']}') ?? 0)}/người',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _costRow(String label, IconData icon, Color color, int value, int maxVal) {
    final frac = maxVal > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark))),
              Text(formatCurrency(value),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mid)),
            ]),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: frac, minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Day timeline ─────────────────────────────────────────────────────────────
  Widget _buildDay(Map<String, dynamic> day) {
    final dayNo = int.tryParse('${day['day_no']}') ?? 1;
    final items = (day['items'] as List?) ?? const [];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
              child: Text('Ngày $dayNo',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 6),
          ...items.whereType<Map>().map((it) => _timelineItem(Map<String, dynamic>.from(it))),
        ],
      ),
    );
  }

  Widget _timelineItem(Map<String, dynamic> it) {
    final slot = _slot(it['time_slot']?.toString() ?? '');
    final title = it['title']?.toString() ?? '';
    final desc = it['description']?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: slot.$3.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(slot.$2, size: 16, color: slot.$3),
          ),
        ]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (slot.$1.isNotEmpty)
              Text(slot.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: slot.$3)),
            Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.dark, height: 1.3)),
            if (desc.isNotEmpty && desc != title) ...[
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12.5, color: AppColors.mid, height: 1.45)),
            ],
          ]),
        ),
      ]),
    );
  }

  // time_slot → (nhãn, icon, màu)
  (String, IconData, Color) _slot(String s) {
    switch (s.toLowerCase()) {
      case 'morning': return ('SÁNG', Icons.wb_sunny_outlined, Color(0xFFF59E0B));
      case 'noon': return ('TRƯA', Icons.lunch_dining_outlined, Color(0xFFF97316));
      case 'afternoon': return ('CHIỀU', Icons.wb_cloudy_outlined, Color(0xFFEA580C));
      case 'evening': return ('TỐI', Icons.nightlight_outlined, Color(0xFF7C3AED));
      case 'night': return ('ĐÊM', Icons.bedtime_outlined, Color(0xFF4F46E5));
      default: return ('', Icons.schedule_outlined, AppColors.primary);
    }
  }

  Widget _chip(IconData icon, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600)),
        ]),
      );
}
