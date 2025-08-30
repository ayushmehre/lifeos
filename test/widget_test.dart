// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifeos/src/app/app.dart';
import 'package:lifeos/src/core/env/env.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final env = const AppEnvironment(
      appName: 'Lifeos',
      openAIApiKey: 'test',
      openAIBaseUrl: 'https://api.openai.com/v1',
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'anon',
      supabaseServiceRoleKey: '',
      supabaseEdgeBaseUrl: 'https://example.functions.supabase.co',
    );

    await tester.pumpWidget(LifeOSApp(environment: env));

    expect(find.text('Lifeos'), findsOneWidget);
  });
}
