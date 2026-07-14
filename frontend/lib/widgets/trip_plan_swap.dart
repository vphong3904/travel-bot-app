// lib/widgets/trip_plan_swap.dart
// Helper đổi khách sạn / điểm / quán trong 1 plan (ai_plan) từ danh sách
// `alternatives`. Dùng chung cho AiPlannerScreen và ChatBotScreen để hành vi
// "Đổi" đồng nhất ở mọi nơi hiển thị lịch trình — đổi tức thì tại chỗ, KHÔNG
// gọi lại AI/RAG, KHÔNG đụng cache. Mutate `plan` tại chỗ rồi gọi `onChanged`
// (caller dùng để setState); vì mutate đúng object ai_plan nên bản đã đổi được
// giữ khi bấm "Lưu Chuyến Đi".
import 'package:flutter/material.dart';

import 'common_widgets.dart';

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

void swapHotel(BuildContext context, Map plan, VoidCallback onChanged) {
  final alts = List<Map<String, dynamic>>.from(
      ((plan['alternatives'] as Map?)?['hotels'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map)));
  if (alts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có khách sạn khác trong dữ liệu.')));
    return;
  }
  _showPickSheet<Map<String, dynamic>>(
    context: context,
    title: 'Chọn khách sạn khác',
    options: alts,
    titleOf: (h) => h['name']?.toString() ?? '',
    subtitleOf: (h) =>
        '${h['stars'] ?? '–'}★ · ${_fmtVnd(h['price_per_night'] as num?)}/đêm',
    onPick: (h) {
      final old = plan['hotel'];
      plan['hotel'] = h;
      alts.remove(h);
      if (old is Map) alts.add(Map<String, dynamic>.from(old));
      (plan['alternatives'] as Map)['hotels'] = alts;
      for (final d in plan['days'] as List) {
        for (final it in (d as Map)['items'] as List) {
          if ((it as Map)['type'] == 'hotel_checkin') {
            it['ref_id'] = h['id'];
            it['title'] = 'Nhận phòng ${h['name']}';
            it['notes'] = h['address'];
          }
        }
      }
      onChanged();
    },
  );
}

void swapItem(BuildContext context, Map plan, Map item, VoidCallback onChanged) {
  final isFood = item['type'] == 'restaurant';
  final key = isFood ? 'restaurants' : 'locations';
  final alts = List<Map<String, dynamic>>.from(
      ((plan['alternatives'] as Map?)?[key] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map)));
  if (alts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isFood
            ? 'Không còn quán ăn khác trong dữ liệu.'
            : 'Không còn địa điểm khác trong dữ liệu.')));
    return;
  }
  _showPickSheet<Map<String, dynamic>>(
    context: context,
    title: isFood ? 'Chọn quán ăn khác' : 'Chọn địa điểm khác',
    options: alts,
    titleOf: (a) => a['name']?.toString() ?? '',
    subtitleOf: (a) => isFood
        ? (a['price_range']?.toString() ?? a['address']?.toString() ?? '')
        : (a['description']?.toString() ?? ''),
    onPick: (a) {
      alts.remove(a);
      (plan['alternatives'] as Map)[key] = alts;
      item['ref_id'] = a['id'];
      if (isFood) {
        item['title'] = 'Ăn tại ${a['name']}';
        item['description'] = (a['specialties'] ?? '').toString().isNotEmpty
            ? 'Đặc sản: ${a['specialties']}'
            : null;
        item['notes'] = a['price_range'];
      } else {
        item['title'] = a['name'];
        item['description'] = a['description'];
        item['notes'] = a['tips'];
        item['estimated_cost'] =
            a['price_adult'] is num ? (a['price_adult'] as num).toInt() : null;
      }
      onChanged();
    },
  );
}

void _showPickSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T) titleOf,
  required String Function(T) subtitleOf,
  required void Function(T) onPick,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (ctx, i) {
                final o = options[i];
                final sub = subtitleOf(o);
                return ListTile(
                  leading: const Icon(Icons.place_outlined, color: AppColors.primary),
                  title:
                      Text(titleOf(o), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: sub.isNotEmpty
                      ? Text(sub,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12))
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    onPick(o);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
