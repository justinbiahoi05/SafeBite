import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/main.dart';

void main() {
  testWidgets('onboarding shows the first page and can swipe forward',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Smart'), findsOneWidget);
    expect(find.text('Scanning'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Track Your'), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
  });
}
