import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numonics/main.dart';

void main() {
  testWidgets('App boots and renders the splash screen', (tester) async {
    await tester.pumpWidget(const NumonicsApp());
    // Firebase isn't available in the test host, so the app holds on the
    // splash. A single pump avoids settling the splash's infinite spinner.
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Numonics'), findsOneWidget);
    expect(find.text('master math, beautifully'), findsOneWidget);
  });
}
