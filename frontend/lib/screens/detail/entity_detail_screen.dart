// lib/screens/detail/entity_detail_screen.dart
// Màn chi tiết dùng chung cho: khách sạn • tour • nhà hàng • món ăn • mua sắm.
// Nhận (type, id) → gọi /travel/items/{type}/{id} → render linh hoạt theo loại.
import 'package:flutter/material.dart';

import '../../services/destination_service.dart';
import '../../services/search_service.dart';
import '../../widgets/common_widgets.dart';
import '../chat/chatbot_screen.dart';
import '../trip_detail/destination_detail_screen.dart';

class _Meta {
  final String label;
  final IconData icon;
  final Color color;
  const _Meta(this.label, this.icon, this.color);
}

const Map<String, _Meta> _kMeta = {
  'hotel': _Meta('Khách sạn', Icons.hotel_rounded, Color(0xFF7C3AED)),
  'tour': _Meta('Tour', Icons.tour_rounded, Color(0xFFD97706)),
  'restaurant': _Meta('Nhà hàng', Icons.restaurant_rounded, Color(0xFFDC2626)),
  'food': _Meta('Món ăn', Icons.ramen_dining_rounded, Color(0xFFEA580C)),
  'shopping': _Meta('Mua sắm', Icons.shopping_bag_rounded, Color(0xFF059669)),
};

class EntityDetailScreen extends StatefulWidget {
  final String type;
  final String id;
  const EntityDetailScreen({super.key, required this.type, required this.id});

  @override
  State<EntityDetailScreen> createState() => _EntityDetailScreenState();
}

class _EntityDetailScreenState extends State<EntityDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _openingDest = false;

  _Meta get _meta => _kMeta[widget.type] ?? _kMeta['hotel']!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await SearchRepository.fetchItemDetail(widget.type, widget.id);
    if (!mounted) return;
    setState(() { _data = d; _loading = false; });
  }

  // ── Field helpers ────────────────────────────────────────────────────────────
  String _s(String k) => _data?[k]?.toString() ?? '';
  int? _i(String k) {
    final v = _data?[k];
    if (v == null) return null;
    return v is int ? v : int.tryParse('$v');
  }
  bool _bool(String k) => _data?[k] == true;
  // Ưu tiên nhãn tiếng Việt (từ content_options), fallback về code gốc.
  String _lbl(String rawKey, String labelKey) {
    final l = _s(labelKey);
    return l.isNotEmpty ? l : _s(rawKey);
  }
  List<String> _arr(String k) {
    final v = _data?[k];
    if (v is List) return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    return const [];
  }
  double _rating() {
    final v = _data?['rating'];
    if (v == null) return 0;
    return v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
  }

  Future<void> _openDestination() async {
    final destId = _s('destination_id');
    if (_openingDest || destId.isEmpty) return;
    setState(() => _openingDest = true);
    final d = await DestinationRepository.fetchDestination(destId);
    if (!mounted) return;
    setState(() => _openingDest = false);
    if (d != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)));
    }
  }

  void _askAi() {
    final where = _s('destination_name');
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatBotScreen(
        initialMessage: 'Cho tôi biết thêm về ${_meta.label.toLowerCase()} "${_s('name')}"'
            '${where.isNotEmpty ? ' ở $where' : ''}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.bg, elevation: 0),
        backgroundColor: AppColors.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_data == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.bg, elevation: 0),
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            const Text('Không tải được thông tin', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () { setState(() => _loading = true); _load(); },
                child: const Text('Thử lại')),
          ]),
        ),
      );
    }

    final img = _s('image_url');
    final where = [_s('destination_name'), _s('province')]
        .where((e) => e.isNotEmpty).toSet().join(' • ');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: _meta.color,
                leading: _circleBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(fit: StackFit.expand, children: [
                    img.isNotEmpty
                        ? Image.network(img, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _heroFallback())
                        : _heroFallback(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: 0.15), Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16, left: 16, right: 16,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _meta.color, borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_meta.icon, size: 13, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(_meta.label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                        const SizedBox(height: 8),
                        Text(_s('name'),
                            style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 8, color: Colors.black45)]),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (where.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Row(children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Expanded(child: Text(where,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ]),
                        ],
                      ]),
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildContent()),
                  ),
                ),
              ),
            ],
          ),
          if (_openingDest)
            Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ── Content theo loại ────────────────────────────────────────────────────────
  List<Widget> _buildContent() {
    final widgets = <Widget>[];

    // Hàng nổi bật: đánh giá + giá
    final chips = <Widget>[];
    if (_rating() > 0) {
      chips.add(_pill(Icons.star_rounded, _rating().toStringAsFixed(1), const Color(0xFFF59E0B)));
    }
    final price = _priceText();
    if (price != null) chips.add(_pill(Icons.payments_outlined, price, _meta.color));
    if (widget.type == 'food' && _bool('must_try')) {
      chips.add(_pill(Icons.local_fire_department_rounded, 'Nên thử', const Color(0xFFDC2626)));
    }
    if (widget.type == 'food' && _bool('vegetarian')) {
      chips.add(_pill(Icons.eco_outlined, 'Có món chay', const Color(0xFF16A34A)));
    }
    if (widget.type == 'restaurant' && _bool('must_try')) {
      chips.add(_pill(Icons.local_fire_department_rounded, 'Đáng thử', const Color(0xFFDC2626)));
    }
    if (chips.isNotEmpty) {
      widgets.add(Wrap(spacing: 8, runSpacing: 8, children: chips));
      widgets.add(const SizedBox(height: 18));
    }

    // Nút hành động
    widgets.add(SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _askAi,
        icon: const Icon(Icons.smart_toy_outlined, size: 18),
        label: Text('Hỏi AI về ${_meta.label.toLowerCase()} này'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ));
    widgets.add(const SizedBox(height: 22));

    // Mô tả
    final desc = _s('description');
    if (desc.isNotEmpty) {
      widgets.add(const _SectionLabel('Giới thiệu'));
      widgets.add(const SizedBox(height: 8));
      widgets.add(Text(desc, style: const TextStyle(fontSize: 14.5, height: 1.65, color: AppColors.mid)));
      widgets.add(const SizedBox(height: 22));
    }

    // Thông tin chi tiết
    final infos = _infoRows();
    if (infos.isNotEmpty) {
      widgets.add(const _SectionLabel('Thông tin'));
      widgets.add(const SizedBox(height: 10));
      widgets.addAll(infos);
      widgets.add(const SizedBox(height: 12));
    }

    // Các danh sách (chips)
    widgets.addAll(_arraySections());

    // Mẹo (restaurant)
    final tips = _s('tips');
    if (tips.isNotEmpty) {
      widgets.add(_InfoCard(icon: Icons.tips_and_updates_outlined, title: 'Mẹo', content: tips));
    }

    // Thuộc điểm đến
    final destName = _s('destination_name');
    if (destName.isNotEmpty) {
      widgets.add(const SizedBox(height: 8));
      widgets.add(_DestLinkCard(name: destName, onTap: _openDestination));
    }

    return widgets;
  }

  List<Widget> _infoRows() {
    final rows = <Widget>[];
    void add(IconData i, String t, String c) {
      if (c.trim().isNotEmpty) rows.add(_InfoCard(icon: i, title: t, content: c));
    }
    switch (widget.type) {
      case 'hotel':
        final stars = _i('stars');
        add(Icons.grade_outlined, 'Hạng',
            [if (stars != null) '$stars★', _s('type')].where((e) => e.isNotEmpty).join(' • '));
        add(Icons.location_on_outlined, 'Địa chỉ', _s('address'));
        break;
      case 'tour':
        add(Icons.schedule_outlined, 'Thời lượng', _s('duration'));
        add(Icons.groups_outlined, 'Quy mô nhóm', _s('group_size'));
        break;
      case 'restaurant':
        add(Icons.restaurant_menu_outlined, 'Loại hình', _lbl('type', 'type_label'));
        add(Icons.access_time_outlined, 'Giờ mở cửa', _s('hours'));
        add(Icons.location_on_outlined, 'Địa chỉ', _s('address'));
        break;
      case 'food':
        add(Icons.translate_outlined, 'Tên gọi khác', _s('local_name'));
        add(Icons.category_outlined, 'Phân loại', _lbl('category', 'category_label'));
        break;
      case 'shopping':
        add(Icons.storefront_outlined, 'Loại', _lbl('type', 'type_label'));
        add(Icons.access_time_outlined, 'Giờ mở cửa', _s('opening_hours'));
        add(Icons.location_on_outlined, 'Địa chỉ', _s('address'));
        break;
    }
    return rows;
  }

  List<Widget> _arraySections() {
    final out = <Widget>[];
    void section(String title, List<String> items, Color color) {
      if (items.isEmpty) return;
      out.add(const SizedBox(height: 6));
      out.add(_SectionLabel(title, size: 15));
      out.add(const SizedBox(height: 8));
      out.add(Wrap(spacing: 7, runSpacing: 7, children: items.map((e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
        child: Text(e, style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600)),
      )).toList()));
      out.add(const SizedBox(height: 14));
    }
    switch (widget.type) {
      case 'hotel':
        section('Tiện nghi', _arr('amenities'), AppColors.primary);
        break;
      case 'tour':
        section('Bao gồm', _arr('includes'), const Color(0xFF16A34A));
        section('Không bao gồm', _arr('excludes'), AppColors.muted);
        break;
      case 'restaurant':
        section('Món đặc trưng', _arr('specialties'), _meta.color);
        break;
      case 'food':
        section('Đặc điểm', _arr('tags'), _meta.color);
        break;
      case 'shopping':
        section('Mặt hàng', _arr('items'), _meta.color);
        break;
    }
    return out;
  }

  String? _priceText() {
    switch (widget.type) {
      case 'hotel':
        final p = _i('price_per_night');
        return (p != null && p > 0) ? '${formatCurrency(p)}/đêm' : null;
      case 'tour':
        final p = _i('price');
        return (p != null && p > 0) ? formatCurrency(p) : null;
      default:
        final pr = _s('price_range');
        return pr.isNotEmpty ? pr : null;
    }
  }

  // ── Small widgets ────────────────────────────────────────────────────────────
  Widget _heroFallback() => Container(
        color: _meta.color.withValues(alpha: 0.85),
        child: Center(child: Icon(_meta.icon, size: 80, color: Colors.white.withValues(alpha: 0.5))),
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      );

  Widget _pill(IconData icon, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
        ]),
      );
}

// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final double size;
  const _SectionLabel(this.text, {this.size = 17});
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: AppColors.dark));
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _InfoCard({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.dark)),
            const SizedBox(height: 4),
            Text(content, style: const TextStyle(fontSize: 13, color: AppColors.mid, height: 1.5)),
          ])),
        ]),
      );
}

class _DestLinkCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _DestLinkCard({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
          ),
          child: Row(children: [
            const Icon(Icons.place_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Thuộc điểm đến', style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ]),
        ),
      );
}
