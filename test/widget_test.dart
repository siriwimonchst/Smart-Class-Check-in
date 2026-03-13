import 'package:flutter_test/flutter_test.dart';
import 'package:smart_checkin_app/main.dart';

void main() {
  testWidgets('SmartCheckinApp renders smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCheckinApp());
    expect(find.text('Smart Class Check-in'), findsWidgets);
  });
}
