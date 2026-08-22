// Basic smoke test: the app boots on the splash screen and shows the brand name.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitrax_mobile/main.dart';

void main() {
  testWidgets('App boots to the VitraX splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const VitraXApp());
    await tester.pump();

    expect(find.text('VitraX'), findsOneWidget);

    // Let the splash screen's bootstrap timer/microtasks finish before the
    // test binding checks for pending timers.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
