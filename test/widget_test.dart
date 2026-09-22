import 'package:flutter_test/flutter_test.dart';
import 'package:aegisyn_ai/main.dart';

void main() {
  testWidgets('AegiSynApp launches and renders branding', (WidgetTester tester) async {
    await tester.pumpWidget(const AegiSynApp());
    expect(find.text('AegiSyn AI'), findsOneWidget);
    expect(find.text('LAUNCH CLINICAL COMMAND CENTER'), findsOneWidget);
  });
}
