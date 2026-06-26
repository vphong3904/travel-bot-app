// lib/screens/explore/destination_list_screen.dart
// Màn hình "Xem tất cả" dùng chung cho mọi loại filter
import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../../services/destination_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/destination_card.dart';
import '../trip_detail/destination_detail_screen.dart';

class DestinationListScreen extends StatefulWidget {
  final String title;
  final String? region;
  final int? budgetMax;
  final int? budgetMin;
  final int? month;
  final String? category;
  final String sortBy;

  const DestinationListScreen({
    super.key,
    required this.title,
    this.region,
    this.budgetMax,
    this.budgetMin,
    this.month,
    this.category,
    this.sortBy = 'rating',
  });

  @override
  State<DestinationListScreen> createState() => _DestinationListScreenState();
}

class _DestinationListScreenState extends State<DestinationListScreen> {
  List<Destination> _dests = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() {
      if (_search != _searchCtrl.text) {
        _search = _searchCtrl.text;
        _load();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await DestinationRepository.fetchDestinations(
        region: widget.region,
        budgetMax: widget.budgetMax,
        budgetMin: widget.budgetMin,
        month: widget.month,
        category: widget.category,
        sortBy: widget.sortBy,
        search: _search.trim().isEmpty ? null : _search.trim(),
        limit: 40,
      );
      if (mounted) setState(() { _dests = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AppSearchBar(
              controller: _searchCtrl,
              hint: 'Tìm trong danh sách...',
              margin: EdgeInsets.zero,
            ),
          ),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${_dests.length} địa điểm',
                    style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _dests.isEmpty
                    ? const Center(child: Text('Không có địa điểm phù hợp'))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.65,
                          mainAxisSpacing: 14, crossAxisSpacing: 14,
                        ),
                        itemCount: _dests.length,
                        itemBuilder: (ctx, i) => DestinationCard(
                          destination: _dests[i],
                          onTap: () => Navigator.push(ctx, MaterialPageRoute(
                              builder: (_) => DestinationDetailScreen(destination: _dests[i]))),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
