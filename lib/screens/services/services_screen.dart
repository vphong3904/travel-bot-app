import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  Map<String, dynamic> results = {'hotels': [], 'tours': [], 'tickets': []};
  bool loading = true;

  static const _tabs = [
    (label: 'Khách sạn', type: 'hotel', icon: Icons.hotel_outlined),
    (label: 'Tour', type: 'tour', icon: Icons.tour_outlined),
    (label: 'Vé', type: 'ticket', icon: Icons.confirmation_number_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _load();
    });
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String q = ''}) async {
    setState(() => loading = true);
    final type = _tabs[_tabCtrl.index].type;
    final data = await ServicesApi.search(q: q, type: type);
    if (mounted) setState(() { results = data; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tra Cứu Dịch Vụ', style: AppTheme.heading(size: 22)),
                    const SizedBox(height: 12),
                    AppSearchBar(
                      controller: _searchCtrl,
                      hint: 'Tìm theo tên, địa điểm...',
                      margin: EdgeInsets.zero,
                      onSubmitted: () => _load(q: _searchCtrl.text),
                    ),
                    TabBar(
                      controller: _tabCtrl,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.muted,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      labelStyle: AppTheme.body(size: 13, weight: FontWeight.w600),
                      unselectedLabelStyle: AppTheme.body(size: 13, weight: FontWeight.w500),
                      tabs: _tabs
                          .map((t) => Tab(
                                height: 56,
                                icon: Icon(t.icon, size: 20),
                                text: t.label,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _ServiceList(items: results['hotels'] ?? [], type: 'hotel'),
                      _ServiceList(items: results['tours'] ?? [], type: 'tour'),
                      _ServiceList(items: results['tickets'] ?? [], type: 'ticket'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  final List<dynamic> items;
  final String type;

  const _ServiceList({required this.items, required this.type});

  IconData get _icon {
    switch (type) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'tour':
        return Icons.tour_rounded;
      default:
        return Icons.confirmation_number_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Không có dữ liệu. Khởi động backend để tải dịch vụ.',
            style: AppTheme.body(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_icon, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: AppTheme.heading(size: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.muted),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                item['destination'] ?? '',
                                style: AppTheme.body(size: 12, color: AppColors.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (type == 'hotel') ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...List.generate(
                      (item['rating'] ?? 4).floor().clamp(0, 5),
                      (_) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                    ),
                    Text('${item['rating']}', style: AppTheme.body(size: 12, weight: FontWeight.w700)),
                    if ((item['type'] ?? '').toString().isNotEmpty)
                      Text('· ${item['type']}', style: AppTheme.body(size: 12, color: AppColors.muted)),
                  ],
                ),
              ],
              if (type == 'tour' && (item['duration'] ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(item['duration'], style: AppTheme.body(size: 12, color: AppColors.muted)),
                ),
              if ((item['description'] ?? '').isNotEmpty && type != 'hotel')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    item['description'],
                    style: AppTheme.body(size: 13, color: AppColors.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      type == 'hotel'
                          ? '${formatCurrency(item['price_per_night'] ?? 0)}/đêm'
                          : formatCurrency(item['price'] ?? 0),
                      style: AppTheme.body(size: 14, color: AppColors.accent, weight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (type == 'hotel') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['availability'] ?? 'Còn phòng',
                        style: AppTheme.body(size: 11, color: AppColors.success, weight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
