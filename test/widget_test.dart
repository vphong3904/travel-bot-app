import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/app_state.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const TravelChatbotApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Chào Mừng'), findsOneWidget);
  });
}
