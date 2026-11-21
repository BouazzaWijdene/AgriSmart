// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:projet/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('AgriSmart affiche la zone et humidité',
          (WidgetTester tester) async {
        await tester.pumpWidget(const AgriSmartApp());

        expect(find.text('AgriSmart'), findsOneWidget);
        expect(find.text('Parcelle Nord (Tomates)'), findsOneWidget);
        expect(find.text('28 %'), findsOneWidget);
        expect(find.text("Besoin d'irrigation"), findsOneWidget);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(find.text('33 %'), findsOneWidget);
      });
}
