import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'chatbot_screen.dart';

class IntentSetupScreen extends StatefulWidget {
  const IntentSetupScreen({super.key});

  @override
  State<IntentSetupScreen> createState() => _IntentSetupScreenState();
}

class _IntentSetupScreenState extends State<IntentSetupScreen> {
  String selectedFrom = 'Hồ Chí Minh';
  String selectedDest = 'Phú Quốc';
  String selectedDuration = '3 ngày 2 đêm';
  String selectedBudget = 'Tầm trung';
  String selectedGroup = 'Gia đình';
  final preferences = <String>{'Biển'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text('Cài Đặt Chuyến Đi', style: AppTheme.heading(size: 18)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Điểm xuất phát'),
                  _selectField(selectedFrom, Icons.location_on_outlined),
                  _fieldLabel('Bạn muốn đi đâu?'),
                  _selectField(selectedDest, Icons.place_outlined),
                  _fieldLabel('Thời gian'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['2 ngày 1 đêm', '3 ngày 2 đêm', '4 ngày 3 đêm'].map((d) {
                      return AppChoiceChip(
                        label: d,
                        selected: selectedDuration == d,
                        onTap: () => setState(() => selectedDuration = d),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _fieldLabel('Ngân sách'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Tiết kiệm', 'Tầm trung', 'Cao cấp'].map((b) {
                      return AppChoiceChip(
                        label: b,
                        selected: selectedBudget == b,
                        onTap: () => setState(() => selectedBudget = b),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _fieldLabel('Nhóm đi'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Gia đình', 'Cặp đôi', 'Solo', 'Nhóm bạn'].map((g) {
                      return AppChoiceChip(
                        label: g,
                        selected: selectedGroup == g,
                        onTap: () => setState(() => selectedGroup = g),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _fieldLabel('Sở thích'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Biển', 'Núi', 'Nghỉ dưỡng', 'Khám phá', 'Ẩm thực'].map((p) {
                      return AppChoiceChip(
                        label: p,
                        selected: preferences.contains(p),
                        onTap: () => setState(() {
                          if (preferences.contains(p)) {
                            preferences.remove(p);
                          } else {
                            preferences.add(p);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text('Bỏ qua', style: AppTheme.heading(size: 15, color: AppColors.mid)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: AppColors.accentGradient),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              final prompt =
                                  'Lên lịch trình đi $selectedDest $selectedDuration cho nhóm $selectedGroup, ngân sách $selectedBudget, sở thích ${preferences.join(", ")}';
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ChatBotScreen(initialMessage: prompt)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('Tạo Lịch Trình', style: AppTheme.heading(size: 16, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text.toUpperCase(), style: AppTheme.label(color: AppColors.mid)),
    );
  }

  Widget _selectField(String value, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: AppTheme.body(size: 15, weight: FontWeight.w600))),
          Icon(icon, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }
}
