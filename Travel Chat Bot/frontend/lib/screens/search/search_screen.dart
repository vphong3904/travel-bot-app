// lib/screens/search/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/destination.dart';
import '../../services/destination_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/destination_card.dart';
import '../trip_detail/destination_detail_screen.dart';

// ─────────────────────────────────────────────
//  Bảng chuyển đổi tiếng Việt không dấu → có dấu (normalize)
// ─────────────────────────────────────────────
class _VietnameseNormalizer {
  static const _map = {
    'a': ['à','á','ả','ã','ạ','ă','ắ','ằ','ẳ','ẵ','ặ','â','ấ','ầ','ẩ','ẫ','ậ'],
    'e': ['è','é','ẻ','ẽ','ẹ','ê','ế','ề','ể','ễ','ệ'],
    'i': ['ì','í','ỉ','ĩ','ị'],
    'o': ['ò','ó','ỏ','õ','ọ','ô','ố','ồ','ổ','ỗ','ộ','ơ','ớ','ờ','ở','ỡ','ợ'],
    'u': ['ù','ú','ủ','ũ','ụ','ư','ứ','ừ','ử','ữ','ự'],
    'y': ['ỳ','ý','ỷ','ỹ','ỵ'],
    'd': ['đ'],
  };

  /// Chuyển chuỗi có dấu → không dấu, lowercase để so sánh
  static String strip(String input) {
    var s = input.toLowerCase();
    _map.forEach((base, variants) {
      for (final v in variants) {
        s = s.replaceAll(v, base);
      }
    });
    return s;
  }

  /// Kiểm tra query (không dấu) có khớp với text (có hoặc không dấu)
  static bool matches(String text, String query) {
    if (query.isEmpty) return true;
    final normalText = strip(text);
    final normalQuery = strip(query);
    return normalText.contains(normalQuery);
  }
}

// ─────────────────────────────────────────────
//  Search Screen
// ─────────────────────────────────────────────
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  List<Destination> _allDests = [];
  List<Destination> _results = [];
  bool _loading = true;
  bool _searched = false;

  Timer? _debounce;

  // Từ khoá tìm kiếm phổ biến gợi ý
  static const _suggestions = [
    'Hà Nội', 'Đà Nẵng', 'Hội An', 'Hạ Long',
    'Sapa', 'Phú Quốc', 'Nha Trang', 'Đà Lạt',
    'Huế', 'Mũi Né', 'Cần Thơ', 'Ninh Bình',
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchCtrl.addListener(_onQueryChanged);
    // Auto focus khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadAll() async {
    try {
      // Tải sẵn tất cả điểm đến để filter local (nhanh hơn)
      final data = await DestinationRepository.fetchDestinations(
        sortBy: 'rating',
        limit: 200,
      );
      if (mounted) setState(() { _allDests = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _doSearch(q));
  }

  void _doSearch(String q) {
    final results = _allDests.where((d) {
      return _VietnameseNormalizer.matches(d.name, q) ||
             _VietnameseNormalizer.matches(d.province ?? '', q) ||
             _VietnameseNormalizer.matches(d.region, q) ||
             _VietnameseNormalizer.matches(d.description ?? '', q);
    }).toList();

    setState(() { _results = results; _searched = true; });
  }

  void _onSuggestionTap(String s) {
    _searchCtrl.text = s;
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: s.length),
    );
    _doSearch(s);
  }

  void _openDetail(Destination d) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(),
        titleSpacing: 0,
      ),
      body: _buildBody(),
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
                hintText: 'Tìm điểm đến, tỉnh thành... (có thể gõ không dấu)',
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Chưa search → hiển thị gợi ý
    if (!_searched) {
      return _buildSuggestions();
    }

    // Đã search nhưng không có kết quả
    if (_results.isEmpty) {
      return _buildEmpty();
    }

    // Có kết quả
    return _buildResults();
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tìm kiếm phổ biến',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gõ có dấu hoặc không dấu đều được!',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((s) => _SuggestionChip(
              label: s,
              onTap: () => _onSuggestionTap(s),
            )).toList(),
          ),
          const SizedBox(height: 28),
          const Text(
            '💡 Ví dụ tìm không dấu',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark),
          ),
          const SizedBox(height: 12),
          _buildTipCard('"ha noi" → Hà Nội', Icons.tips_and_updates_outlined),
          const SizedBox(height: 8),
          _buildTipCard('"da nang" → Đà Nẵng', Icons.tips_and_updates_outlined),
          const SizedBox(height: 8),
          _buildTipCard('"ha long" → Hạ Long', Icons.tips_and_updates_outlined),
        ],
      ),
    );
  }

  Widget _buildTipCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
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
            Text(
              'Không tìm thấy kết quả cho\n"$q"',
              style: const TextStyle(fontSize: 15, color: AppColors.dark, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Thử tìm kiếm với từ khác\nhoặc không dấu cũng được nhé!',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: _suggestions.take(4).map((s) => _SuggestionChip(
                label: s,
                onTap: () => _onSuggestionTap(s),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final q = _searchCtrl.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(
            'Tìm thấy ${_results.length} kết quả cho "$q"',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: _results.length,
            itemBuilder: (ctx, i) => DestinationCard(
              destination: _results[i],
              onTap: () => _openDetail(_results[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Chip gợi ý
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_rounded, size: 13, color: AppColors.muted),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.dark, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}