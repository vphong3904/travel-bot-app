import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import '../../main_navigation.dart';
import '../../widgets/common_widgets.dart';

class IntentSetupScreen extends StatefulWidget {
  const IntentSetupScreen({super.key});

  @override
  State<IntentSetupScreen> createState() => _IntentSetupScreenState();
}

class _IntentSetupScreenState extends State<IntentSetupScreen> {
  final _fromCtrl = TextEditingController(text: 'Hồ Chí Minh');
  final _destCtrl = TextEditingController(text: 'Phú Quốc');
  String selectedDuration = '3 ngày 2 đêm';
  String selectedBudget = 'Tầm trung';
  String selectedGroup = 'Gia đình';
  final preferences = <String>{'Biển'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Cài đặt chuyến đi cùng AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cung cấp thông tin để AI thiết kế lịch trình cá nhân hóa qua RAG + NLP.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(controller: _fromCtrl, decoration: const InputDecoration(labelText: 'Điểm xuất phát', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 16),
            TextField(controller: _destCtrl, decoration: const InputDecoration(labelText: 'Bạn muốn đi đâu?', prefixIcon: Icon(Icons.flight_land_rounded))),
            const SizedBox(height: 24),
            const Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['2 ngày 1 đêm', '3 ngày 2 đêm', '4 ngày 3 đêm'].map((d) {
                return ChoiceChip(
                  label: Text(d),
                  selected: selectedDuration == d,
                  onSelected: (_) => setState(() => selectedDuration = d),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Ngân sách', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Tiết kiệm', 'Tầm trung', 'Cao cấp'].map((b) {
                return ChoiceChip(
                  label: Text(b),
                  selected: selectedBudget == b,
                  onSelected: (_) => setState(() => selectedBudget = b),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Nhóm đi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Gia đình', 'Cặp đôi', 'Solo', 'Nhóm bạn'].map((g) {
                return ChoiceChip(
                  label: Text(g),
                  selected: selectedGroup == g,
                  onSelected: (_) => setState(() => selectedGroup = g),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Sở thích', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Biển', 'Núi', 'Nghỉ dưỡng', 'Khám phá', 'Ẩm thực'].map((p) {
                final selected = preferences.contains(p);
                return FilterChip(
                  label: Text(p),
                  selected: selected,
                  onSelected: (v) => setState(() => v ? preferences.add(p) : preferences.remove(p)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'AI sẽ tự động chọn intent phù hợp và fallback khi độ tin cậy thấp để đảm bảo trả lời chính xác hơn.',
              style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen())),
                    child: const Text('Bỏ qua'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final prompt = 'Lên lịch trình đi ${_destCtrl.text} $selectedDuration cho nhóm $selectedGroup, ngân sách $selectedBudget, sở thích ${preferences.join(", ")}';
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatBotScreen(initialMessage: prompt)));
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Tạo lịch trình AI'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
