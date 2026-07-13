// lib/screens/trip/ai_planner_screen.dart
// TP-006 — AI Trip Planner: form thu thập nhu cầu (thiếu gì hỏi đó) →
// draft lịch trình (đổi từng điểm từ alternatives) → xác nhận lưu chuyến đi.
// Contract: .agent/trip-ai/TRIP_AI_ROADMAP.md §2.1–2.2.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../services/trip_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_register_screen.dart';

const _prefOptions = <String, String>{
  'biển': 'Biển đảo',
  'núi': 'Núi rừng',
  'thiên_nhiên': 'Thiên nhiên',
  'healing': 'Chill / Healing',
  'văn_hoá': 'Văn hoá',
  'ẩm_thực': 'Ẩm thực',
  'phượt': 'Phượt',
  'gia_đình': 'Gia đình',
  'sống_ảo': 'Sống ảo',
  'mua_sắm': 'Mua sắm',
  'tâm_linh': 'Tâm linh',
  'giải_trí': 'Giải trí',
};

// 'group' khớp CHECK constraint trip_plans.travel_type ở backend
// ('solo','couple','family','group') — trước đây dùng 'friends' khiến lưu
// chuyến đi bị lỗi (IntegrityError) khi chọn "Nhóm bạn".
const _travelTypes = <String, String>{
  'solo': 'Một mình',
  'couple': 'Cặp đôi',
  'family': 'Gia đình',
  'group': 'Nhóm bạn',
};

const _slotLabels = <String, String>{
  'morning': 'Sáng',
  'lunch': 'Trưa',
  'afternoon': 'Chiều',
  'evening': 'Tối',
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

class AiPlannerScreen extends StatefulWidget {
  /// Khi được truyền sẵn (vd từ nút "Gợi ý lịch trình" ở màn chi tiết thành
  /// phố), màn tự điền + gọi /trips/ai/plan NGAY khi mở — hiện thẳng 1 lịch
  /// trình mẫu, không bắt user điền form hay chat từng bước.
  final String? initialDestination;
  final int? initialDays;

  const AiPlannerScreen({super.key, this.initialDestination, this.initialDays});

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> {
  final _destCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  int _travelers = 1;
  String? _travelType;
  final Set<String> _prefs = {};
  DateTime? _startDate;

  bool _loading = false;
  List<String> _questions = [];
  List<String> _missing = [];
  Map<String, dynamic>? _plan; // draft plan từ backend

  TripApiService _api(AppState s) => TripApiService(
        tokenProvider: () => s.token,
        tokenRefresher: () => s.refreshAccessToken(),
      );

  @override
  void initState() {
    super.initState();
    // Mở từ nút "Gợi ý lịch trình" (destination_detail_screen) → có sẵn
    // destination → điền form + gọi /trips/ai/plan luôn (skip_optional),
    // hiện thẳng lịch trình mẫu, không bắt user điền lại hay chat từng bước.
    final dest = widget.initialDestination;
    if (dest != null && dest.isNotEmpty) {
      _destCtrl.text = dest;
      _daysCtrl.text = '${widget.initialDays ?? 3}';
      WidgetsBinding.instance.addPostFrameCallback((_) => _submit(skipOptional: true));
    }
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    _daysCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  // ── Gọi /trips/ai/plan ──────────────────────────────────────────────────────
  Map<String, dynamic> _payload({required bool skipOptional}) => {
        if (_destCtrl.text.trim().isNotEmpty) 'destination': _destCtrl.text.trim(),
        if (int.tryParse(_daysCtrl.text) != null) 'days': int.parse(_daysCtrl.text),
        if (_startDate != null)
          'start_date': _startDate!.toIso8601String().substring(0, 10),
        if (int.tryParse(_budgetCtrl.text.replaceAll('.', '')) != null)
          'budget': int.parse(_budgetCtrl.text.replaceAll('.', '')),
        'travelers': _travelers,
        if (_travelType != null) 'travel_type': _travelType,
        if (_prefs.isNotEmpty) 'preferences': _prefs.toList(),
        'skip_optional': skipOptional,
      };

  Future<void> _submit({bool skipOptional = false}) async {
    final s = context.read<AppState>();
    setState(() { _loading = true; _questions = []; _missing = []; });
    try {
      final res = await _api(s).aiPlan(_payload(skipOptional: skipOptional));
      if (!mounted) return;
      if (res['status'] == 'need_info') {
        setState(() {
          _loading = false;
          _questions = (res['questions'] as List? ?? []).map((e) => '$e').toList();
          _missing = (res['missing_fields'] as List? ?? []).map((e) => '$e').toList();
        });
      } else {
        setState(() {
          _loading = false;
          _plan = Map<String, dynamic>.from(res['plan'] as Map);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  // ── Gọi /trips/ai/confirm ───────────────────────────────────────────────────
  Future<void> _confirm() async {
    final p = _plan;
    if (p == null) return;
    final s = context.read<AppState>();
    setState(() => _loading = true);
    try {
      await _api(s).aiConfirm({
        'title': p['title'],
        if (p['destination_id'] != null) 'destination_id': p['destination_id'],
        if (p['start_date'] != null) 'start_date': p['start_date'],
        if (p['end_date'] != null) 'end_date': p['end_date'],
        'days_count': p['days_count'],
        'travelers': p['travelers'],
        if (p['travel_type'] != null) 'travel_type': p['travel_type'],
        if (p['budget'] != null) 'budget': p['budget'],
        if (p['estimated_cost'] != null) 'estimated_cost': p['estimated_cost'],
        if (p['summary'] != null) 'summary': p['summary'],
        'days': p['days'],
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã lưu chuyến đi! Xem lại ở tab "Chuyến đi".')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi lưu: ${friendlyError(e)}')));
    }
  }

  // ── Đổi lựa chọn từ alternatives ────────────────────────────────────────────
  void _swapHotel() {
    final p = _plan;
    if (p == null) return;
    final alts = List<Map<String, dynamic>>.from(
        ((p['alternatives'] as Map?)?['hotels'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)));
    if (alts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có khách sạn khác trong dữ liệu.')));
      return;
    }
    _showPickSheet<Map<String, dynamic>>(
      title: 'Chọn khách sạn khác',
      options: alts,
      titleOf: (h) => h['name']?.toString() ?? '',
      subtitleOf: (h) =>
          '${h['stars'] ?? '–'}★ · ${_fmtVnd(h['price_per_night'] as num?)}/đêm',
      onPick: (h) {
        setState(() {
          final old = p['hotel'];
          p['hotel'] = h;
          alts.remove(h);
          if (old is Map) alts.add(Map<String, dynamic>.from(old));
          (p['alternatives'] as Map)['hotels'] = alts;
          // cập nhật item nhận phòng ngày 1
          for (final d in p['days'] as List) {
            for (final it in (d as Map)['items'] as List) {
              if ((it as Map)['type'] == 'hotel_checkin') {
                it['ref_id'] = h['id'];
                it['title'] = 'Nhận phòng ${h['name']}';
                it['notes'] = h['address'];
              }
            }
          }
        });
      },
    );
  }

  // Nhận Map (không copy) để mutate trực tiếp item bên trong _plan.
  void _swapItem(Map item) {
    final p = _plan;
    if (p == null) return;
    final isFood = item['type'] == 'restaurant';
    final key = isFood ? 'restaurants' : 'locations';
    final alts = List<Map<String, dynamic>>.from(
        ((p['alternatives'] as Map?)?[key] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)));
    if (alts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isFood
              ? 'Không còn quán ăn khác trong dữ liệu.'
              : 'Không còn địa điểm khác trong dữ liệu.')));
      return;
    }
    _showPickSheet<Map<String, dynamic>>(
      title: isFood ? 'Chọn quán ăn khác' : 'Chọn địa điểm khác',
      options: alts,
      titleOf: (a) => a['name']?.toString() ?? '',
      subtitleOf: (a) => isFood
          ? (a['price_range']?.toString() ?? a['address']?.toString() ?? '')
          : (a['description']?.toString() ?? ''),
      onPick: (a) {
        setState(() {
          alts.remove(a);
          (p['alternatives'] as Map)[key] = alts;
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
        });
      },
    );
  }

  void _showPickSheet<T>({
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
                    title: Text(titleOf(o),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: sub.isNotEmpty
                        ? Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12))
                        : null,
                    onTap: () { Navigator.pop(ctx); onPick(o); },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<AppState>().isLoggedIn;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
          const SizedBox(width: 8),
          Text(_plan == null ? 'AI lên lịch trình' : 'Lịch trình đề xuất',
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark)),
        ]),
        leading: _plan != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.dark),
                onPressed: () => setState(() => _plan = null))
            : null,
      ),
      body: !loggedIn
          ? _loginPrompt()
          : _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _plan == null
                  ? _buildForm()
                  : _buildDraft(),
    );
  }

  Widget _loginPrompt() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.muted),
            const SizedBox(height: 14),
            const Text('Đăng nhập để AI lên lịch trình cho bạn',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.dark)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginRegisterScreen())),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Đăng nhập'),
            ),
          ]),
        ),
      );

  // ── Bước 1: Form nhu cầu ───────────────────────────────────────────────────
  Widget _buildForm() {
    final onlyOptionalMissing = _missing.isNotEmpty &&
        !_missing.contains('destination') && !_missing.contains('days');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_questions.isNotEmpty) _questionBanner(onlyOptionalMissing),
        _label('Bạn muốn đi đâu? *', highlight: _missing.contains('destination')),
        TextField(
          controller: _destCtrl,
          decoration: _input('VD: Đà Lạt, Phú Quốc, Sa Pa...'),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Mấy ngày? *', highlight: _missing.contains('days')),
              TextField(
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                decoration: _input('VD: 3'),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Ngày khởi hành'),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
                child: InputDecorator(
                  decoration: _input(''),
                  child: Text(
                    _startDate == null
                        ? 'Chọn ngày'
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                    style: TextStyle(
                        fontSize: 14,
                        color: _startDate == null ? AppColors.muted : AppColors.dark),
                  ),
                ),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        _label('Ngân sách cả chuyến (VND)', highlight: _missing.contains('budget')),
        TextField(
          controller: _budgetCtrl,
          keyboardType: TextInputType.number,
          decoration: _input('VD: 5000000 (bỏ trống nếu chưa rõ)'),
        ),
        const SizedBox(height: 14),
        _label('Số người', highlight: _missing.contains('travelers')),
        Row(children: [
          IconButton(
            onPressed: _travelers > 1 ? () => setState(() => _travelers--) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$_travelers người',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          IconButton(
            onPressed: () => setState(() => _travelers++),
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          ),
        ]),
        const SizedBox(height: 8),
        _label('Đi với ai?', highlight: _missing.contains('travel_type')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _travelTypes.entries.map((e) {
            final selected = _travelType == e.key;
            return ChoiceChip(
              label: Text(e.value),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.dark, fontSize: 13),
              onSelected: (_) => setState(() => _travelType = e.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _label('Sở thích (chọn nhiều — bỏ trống AI sẽ tự đoán từ lịch sử của bạn)',
            highlight: _missing.contains('preferences')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _prefOptions.entries.map((e) {
            final selected = _prefs.contains(e.key);
            return FilterChip(
              label: Text(e.value),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.dark, fontSize: 13),
              onSelected: (v) => setState(() {
                if (v) {
                  _prefs.add(e.key);
                } else {
                  _prefs.remove(e.key);
                }
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _submit(),
          icon: const Icon(Icons.auto_awesome, size: 18),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          label: const Text('AI lên lịch trình',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _questionBanner(bool onlyOptionalMissing) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.help_outline, size: 16, color: AppColors.secondary),
            SizedBox(width: 6),
            Text('AI cần thêm thông tin:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppColors.dark)),
          ]),
          const SizedBox(height: 6),
          ..._questions.map((q) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $q',
                    style: const TextStyle(fontSize: 13, color: AppColors.dark)),
              )),
          if (onlyOptionalMissing) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _submit(skipOptional: true),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Bỏ qua, lên lịch trình luôn →',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ),
          ],
        ]),
      );

  Widget _label(String text, {bool highlight = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: highlight ? AppColors.error : AppColors.dark)),
      );

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.muted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
      );

  // ── Bước 2: Draft plan — tổng kết + đổi lựa chọn + xác nhận ────────────────
  Widget _buildDraft() {
    final p = _plan!;
    final days = (p['days'] as List? ?? []);
    final hotel = p['hotel'] as Map?;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(p['title']?.toString() ?? 'Lịch trình',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
            const SizedBox(height: 6),
            Wrap(spacing: 12, runSpacing: 4, children: [
              _metaChip(Icons.calendar_today_outlined, '${p['days_count']} ngày'),
              _metaChip(Icons.group_outlined, '${p['travelers']} người'),
              if (p['budget'] != null)
                _metaChip(Icons.account_balance_wallet_outlined,
                    'NS ${_fmtVnd(p['budget'] as num?)}'),
              _metaChip(Icons.payments_outlined,
                  'Ước tính ${_fmtVnd(p['estimated_cost'] as num?)}'),
            ]),
            if (p['summary'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(p['summary'].toString(),
                    style: const TextStyle(fontSize: 13, color: AppColors.dark, height: 1.5)),
              ),
            ],
            if (p['budget_warning'] != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(p['budget_warning'].toString(),
                          style: const TextStyle(fontSize: 12, color: AppColors.error))),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            if (hotel != null) _hotelCard(Map<String, dynamic>.from(hotel)),
            const SizedBox(height: 8),
            ...days.map((d) => _dayCard(Map<String, dynamic>.from(d as Map))),
            const SizedBox(height: 90),
          ],
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _plan = null),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Sửa yêu cầu'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: const Text('Lưu chuyến đi',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _metaChip(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        ],
      );

  Widget _hotelCard(Map<String, dynamic> h) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.hotel_outlined, color: AppColors.secondary),
          ),
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
          TextButton(onPressed: _swapHotel, child: const Text('Đổi')),
        ]),
      );

  Widget _dayCard(Map<String, dynamic> d) {
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
        const SizedBox(height: 8),
        ...items.map((raw) {
          final it = raw as Map;
          final canSwap = it['type'] == 'location' || it['type'] == 'restaurant';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 52,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_slotLabels[it['time_slot']] ?? '',
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.bold,
                          color: AppColors.secondary)),
                  if (it['start_time'] != null)
                    Text(it['start_time'].toString(),
                        style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ]),
              ),
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
                  onTap: () => _swapItem(it),
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
