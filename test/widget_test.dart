// Basic widget test for AnyBankApp.
//
// Verifies that the root widget builds a MaterialApp.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anybank/app/app.dart';

void main() {
  testWidgets('AnyBankApp builds MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const AnyBankApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
