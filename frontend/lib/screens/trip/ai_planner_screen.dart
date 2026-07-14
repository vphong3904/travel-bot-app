// lib/screens/trip/ai_planner_screen.dart
// TP-006 — AI Trip Planner: form thu thập nhu cầu → soạn 1 câu thoại tự
// nhiên GỬI QUA CHAT THẬT (cùng pipeline trip_chat_planner.py với chatbot,
// không tự gọi /trips/ai/plan riêng nữa — tránh 2 luồng lệch nhau) → draft
// lịch trình (đổi từng điểm từ alternatives) → xác nhận lưu chuyến đi.
// Nếu 1 câu chưa đủ (hiếm, vì đã soạn đủ thông tin form thu thập được), AI
// sẽ hỏi lại — màn này điều hướng thẳng sang ChatBotScreen để user gõ tiếp
// tự nhiên, không dựng lại UI hỏi-đáp riêng.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../services/chat_api_service.dart';
import '../../services/chat_stream_utils.dart';
import '../../services/trip_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/trip_plan_view.dart';
import '../auth/login_register_screen.dart';
import '../chat/chatbot_screen.dart';

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

// Từ khoá khớp _TRAVEL_TYPE_KEYWORDS/_extract_travel_type ở
// trip_chat_planner.py — soạn câu đúng từ để AI nhận diện được travel_type
// trong 1 lượt, không cần hỏi lại.
const _travelTypePhrase = <String, String>{
  'solo': 'đi một mình',
  'couple': 'đi cùng người yêu',
  'family': 'đi cùng gia đình',
  'group': 'đi cùng nhóm bạn',
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
  String? _pendingQuestion; // câu hỏi AI trả lời khi 1 câu chưa đủ thông tin
  String? _sessionId; // session chat thật đứng sau — hiện bình thường ở lịch sử chat
  Map<String, dynamic>? _plan; // draft plan (ai_plan) từ backend

  TripApiService _api(AppState s) => TripApiService(
        tokenProvider: () => s.token,
        tokenRefresher: () => s.refreshAccessToken(),
      );

  ChatSessionApiService _chatApi(AppState s) => ChatSessionApiService(
        tokenProvider: () => s.token,
        tokenRefresher: () => s.refreshAccessToken(),
      );

  @override
  void initState() {
    super.initState();
    // Mở từ nút "Gợi ý lịch trình" (destination_detail_screen) → có sẵn
    // destination → điền form + gửi câu thoại luôn (bỏ qua tuỳ chọn), hiện
    // thẳng lịch trình mẫu, không bắt user điền lại hay chat từng bước.
    final dest = widget.initialDestination;
    if (dest != null && dest.isNotEmpty) {
      _destCtrl.text = dest;
      _daysCtrl.text = '${widget.initialDays ?? 3}';
      WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
    }
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    _daysCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  // ── Soạn 1 câu thoại tự nhiên từ form — gửi qua CHAT THẬT thay vì tự gọi
  // /trips/ai/plan riêng (đồng bộ với luồng chat, dùng chung
  // trip_chat_planner.py). Dùng đúng từ khoá mà các hàm trích xuất slot ở
  // backend nhận diện được để giải quyết đủ trong 1 lượt, không cần hỏi lại.
  String _composeMessage() {
    final dest = _destCtrl.text.trim();
    final days = int.tryParse(_daysCtrl.text) ?? widget.initialDays ?? 3;
    final parts = <String>['Lên lịch trình đi $dest $days ngày'];

    var hasOptional = false;
    if (_travelType != null) {
      var phrase = _travelTypePhrase[_travelType]!;
      if ((_travelType == 'family' || _travelType == 'group') && _travelers > 2) {
        phrase += ' $_travelers người';
      }
      parts.add(phrase);
      hasOptional = true;
    } else if (_travelers > 1) {
      parts.add('đi $_travelers người');
      hasOptional = true;
    }

    final budgetVal = int.tryParse(_budgetCtrl.text.replaceAll('.', ''));
    if (budgetVal != null && budgetVal > 0) {
      parts.add(budgetVal % 1000000 == 0
          ? 'ngân sách ${budgetVal ~/ 1000000} triệu'
          : 'ngân sách $budgetVal đồng');
      hasOptional = true;
    }

    if (_prefs.isNotEmpty) {
      parts.add('thích ${_prefs.map((k) => _prefOptions[k] ?? k).join(', ')}');
      hasOptional = true;
    }

    // Form không có field nào để nhập tuỳ chọn thêm → báo AI bỏ qua luôn
    // thay vì hỏi lại (trùng nghĩa "bỏ qua" trong _SKIP_WORDS backend).
    if (!hasOptional) parts.add('bỏ qua các lựa chọn khác');

    return '${parts.join(", ")}.';
  }

  Future<void> _submit() async {
    if (_destCtrl.text.trim().isEmpty || _daysCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nhập điểm đến và số ngày nhé.')));
      return;
    }
    final s = context.read<AppState>();
    setState(() { _loading = true; _pendingQuestion = null; });
    try {
      final chatApi = _chatApi(s);
      _sessionId ??= (await chatApi.createSession(title: 'Lịch trình ${_destCtrl.text.trim()}')).id;
      final result = await collectChatStream(
        chatApi.sendMessageStream(_sessionId!, _composeMessage()),
      );
      if (!mounted) return;
      final aiPlan = result.itinerary?['ai_plan'];
      if (aiPlan is Map) {
        setState(() {
          _loading = false;
          _plan = Map<String, dynamic>.from(aiPlan);
        });
      } else {
        // AI vẫn cần hỏi thêm (hiếm) — hiện câu hỏi, cho phép tiếp tục ở
        // ChatBotScreen thật thay vì dựng lại UI hỏi-đáp riêng ở đây.
        setState(() {
          _loading = false;
          _pendingQuestion = result.text.isNotEmpty
              ? result.text
              : 'Mình cần thêm thông tin — bạn tiếp tục trò chuyện nhé.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  void _continueInChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatBotScreen(sessionId: _sessionId)),
    );
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_pendingQuestion != null) _questionBanner(),
        _label('Bạn muốn đi đâu? *'),
        TextField(
          controller: _destCtrl,
          decoration: _input('VD: Đà Lạt, Phú Quốc, Sa Pa...'),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Mấy ngày? *'),
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
        _label('Ngân sách cả chuyến (VND)'),
        TextField(
          controller: _budgetCtrl,
          keyboardType: TextInputType.number,
          decoration: _input('VD: 5000000 (bỏ trống nếu chưa rõ)'),
        ),
        const SizedBox(height: 14),
        _label('Số người'),
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
        _label('Đi với ai?'),
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
        _label('Sở thích (chọn nhiều — bỏ trống AI sẽ tự đoán từ lịch sử của bạn)'),
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

  // AI chưa đủ thông tin từ 1 câu ghép (hiếm) → hiện câu hỏi + cho tiếp tục
  // ở ChatBotScreen thật (dùng lại _sessionId đã tạo), không dựng UI hỏi-đáp
  // riêng ở màn này.
  Widget _questionBanner() => Container(
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
          Text(_pendingQuestion ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.dark)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _continueInChat,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Tiếp tục trò chuyện →',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ),
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
  // Dùng chung TripPlanView (widgets/trip_plan_view.dart) với chatbot_screen
  // và TripDetailsScreen — cùng 1 chỗ hiển thị ảnh/hotel/timeline, không vẽ
  // riêng ở đây nữa (trước đây _metaChip/_hotelCard/_dayCard chỉ có ở màn
  // này, chat chỉ có bare text — giờ đồng bộ cả 2 nơi).
  Widget _buildDraft() {
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TripPlanView(plan: _plan!, onSwapHotel: _swapHotel, onSwapItem: _swapItem),
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

}
