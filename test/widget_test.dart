import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_stream/app.dart';

void main() {
  testWidgets('AuraStreamApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AuraStreamApp());
    expect(find.byType(AuraStreamApp), findsOneWidget);
  });
}
