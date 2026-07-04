// lib/screens/search/search_screen.dart
// Tra cứu tổng hợp: điểm đến • khách sạn • tour • nhà hàng • món ăn • mua sắm.
// Gọi /travel/search (backend tìm không dấu). Lọc theo loại bằng chip.
import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/destination_service.dart';
import '../../services/search_service.dart';
import '../../widgets/common_widgets.dart';
import '../detail/entity_detail_screen.dart';
import '../trip_detail/destination_detail_screen.dart';

// Nhãn / icon / màu cho từng loại kết quả.
class _TypeMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _TypeMeta(this.label, this.icon, this.color);
}

const Map<String, _TypeMeta> _kTypeMeta = {
  'destination': _TypeMeta('Điểm đến', Icons.place_rounded, Color(0xFF2563EB)),
  'hotel': _TypeMeta('Khách sạn', Icons.hotel_rounded, Color(0xFF7C3AED)),
  'tour': _TypeMeta('Tour', Icons.tour_rounded, Color(0xFFD97706)),
  'restaurant': _TypeMeta('Nhà hàng', Icons.restaurant_rounded, Color(0xFFDC2626)),
  'food': _TypeMeta('Món ăn', Icons.ramen_dining_rounded, Color(0xFFEA580C)),
  'shopping': _TypeMeta('Mua sắm', Icons.shopping_bag_rounded, Color(0xFF059669)),
};
const List<String> _kTypeOrder = [
  'destination', 'hotel', 'tour', 'restaurant', 'food', 'shopping',
];

class SearchScreen extends StatefulWidget {
  /// Khi nhúng làm tab (không có màn hình phía sau để pop) → ẩn nút back.
  final bool embedded;
  const SearchScreen({super.key, this.embedded = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  SearchResult _result = SearchResult.empty;
  bool _loading = false;
  bool _searched = false;
  bool _opening = false;
  String _typeFilter = 'all';

  static const _suggestions = [
    'Hà Nội', 'Đà Nẵng', 'Hội An', 'Hạ Long',
    'Sapa', 'Phú Quốc', 'Nha Trang', 'Đà Lạt',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onQueryChanged);
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() { _result = SearchResult.empty; _searched = false; _loading = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _doSearch(q));
  }

  Future<void> _doSearch(String q) async {
    if (q.isEmpty) return;
    setState(() { _loading = true; _searched = true; });
    final res = await SearchRepository.searchAll(q);
    if (!mounted || _searchCtrl.text.trim() != q) return;
    setState(() { _result = res; _loading = false; _typeFilter = 'all'; });
  }

  void _onSuggestionTap(String s) {
    _searchCtrl.text = s;
    _searchCtrl.selection = TextSelection.fromPosition(TextPosition(offset: s.length));
    _doSearch(s);
  }

  List<SearchItem> get _filtered => _typeFilter == 'all'
      ? _result.results
      : _result.results.where((e) => e.type == _typeFilter).toList();

  // Mở chi tiết theo loại: điểm đến → màn destination; loại khác → EntityDetail.
  Future<void> _openItem(SearchItem item) async {
    if (_opening) return;
    if (item.type == 'destination') {
      if (item.destinationId.isEmpty) return;
      setState(() => _opening = true);
      final d = await DestinationRepository.fetchDestination(item.destinationId);
      if (!mounted) return;
      setState(() => _opening = false);
      if (d != null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không mở được, thử lại sau')));
      }
      return;
    }
    // hotel / tour / restaurant / food / shopping
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EntityDetailScreen(type: item.type, id: item.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.dark),
                onPressed: () => Navigator.pop(context),
              ),
        titleSpacing: widget.embedded ? 16 : 0,
        title: _buildSearchField(),
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_opening)
            Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focusNode,
              style: const TextStyle(fontSize: 14, color: AppColors.dark),
              decoration: const InputDecoration(
                hintText: 'Điểm đến, khách sạn, món ăn... (gõ không dấu)',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => _doSearch(q.trim()),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchCtrl,
            builder: (_, val, __) => val.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      _focusNode.requestFocus();
                    },
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_searched) return _buildSuggestions();
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_result.total == 0) return _buildEmpty();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeFilter(),
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Text('Không có ${_kTypeMeta[_typeFilter]?.label ?? 'kết quả'} phù hợp',
                      style: const TextStyle(color: AppColors.muted)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ResultCard(
                    item: _filtered[i], onTap: () => _openItem(_filtered[i])),
                ),
        ),
      ],
    );
  }

  // Chip lọc theo loại (chỉ hiện loại có kết quả).
  Widget _buildTypeFilter() {
    final chips = <Widget>[
      _FilterChip(
        label: 'Tất cả', count: _result.total,
        selected: _typeFilter == 'all',
        onTap: () => setState(() => _typeFilter = 'all'),
      ),
    ];
    for (final t in _kTypeOrder) {
      final c = _result.counts[t] ?? 0;
      if (c == 0) continue;
      final meta = _kTypeMeta[t]!;
      chips.add(_FilterChip(
        label: meta.label, count: c, color: meta.color, icon: meta.icon,
        selected: _typeFilter == t,
        onTap: () => setState(() => _typeFilter = t),
      ));
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tra cứu mọi thứ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
          const SizedBox(height: 4),
          const Text('Điểm đến, khách sạn, tour, nhà hàng, món ăn, mua sắm — gõ có dấu hoặc không dấu đều được.',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 16),
          // Các loại có thể tra cứu
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _kTypeOrder.map((t) {
              final m = _kTypeMeta[t]!;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(m.icon, size: 15, color: m.color),
                  const SizedBox(width: 6),
                  Text(m.label,
                      style: TextStyle(fontSize: 12.5, color: m.color, fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList(),
          ),
          const SizedBox(height: 26),
          const Text('Tìm kiếm phổ biến',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _suggestions.map((s) => _SuggestionChip(
                label: s, onTap: () => _onSuggestionTap(s))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final q = _searchCtrl.text.trim();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColors.muted.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Không tìm thấy kết quả cho\n"$q"',
                style: const TextStyle(fontSize: 15, color: AppColors.dark, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Thử từ khác hoặc tên tỉnh/thành nhé!',
                style: TextStyle(fontSize: 13, color: AppColors.muted), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: _suggestions.take(4).map((s) => _SuggestionChip(
                  label: s, onTap: () => _onSuggestionTap(s))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Result card (mọi loại)
// ─────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final SearchItem item;
  final VoidCallback onTap;
  const _ResultCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final meta = _kTypeMeta[item.type] ?? _kTypeMeta['destination']!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: SizedBox(
                width: 92, height: 92,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(item.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ph(meta))
                    : _ph(meta),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(meta.icon, size: 11, color: meta.color),
                        const SizedBox(width: 4),
                        Text(meta.label,
                            style: TextStyle(fontSize: 10, color: meta.color, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                    const SizedBox(height: 5),
                    Text(item.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dark),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.muted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(item.subtitle,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      if (item.rating > 0) ...[
                        const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(item.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.dark)),
                        const SizedBox(width: 8),
                      ],
                      if (item.tag != null && item.tag!.isNotEmpty)
                        Flexible(
                          child: Text(item.tag!,
                              style: const TextStyle(fontSize: 11, color: AppColors.muted),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      const Spacer(),
                      if (item.price != null && item.price!.isNotEmpty)
                        Text(item.price!,
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: meta.color)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph(_TypeMeta meta) => Container(
        color: meta.color.withValues(alpha: 0.08),
        child: Icon(meta.icon, color: meta.color.withValues(alpha: 0.5), size: 30),
      );
}

// ─────────────────────────────────────────────
//  Filter chip (theo loại)
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : color),
              const SizedBox(width: 5),
            ],
            Text('$label ($count)',
                style: TextStyle(
                  fontSize: 12.5,
                  color: selected ? Colors.white : AppColors.dark,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Suggestion chip
// ─────────────────────────────────────────────
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_rounded, size: 14, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.dark)),
          ],
        ),
      ),
    );
  }
}
