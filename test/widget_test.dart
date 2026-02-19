import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_dashboard/main.dart';

void main() {
  testWidgets('App launches and shows Command Center', (WidgetTester tester) async {
    await tester.pumpWidget(const EnterpriseDashboardApp());
    expect(find.text('COMMAND CENTER'), findsOneWidget);
  });
}
