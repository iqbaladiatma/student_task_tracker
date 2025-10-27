// This is a basic Flutter widget test for the main app initialization.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_task_tracker/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentTaskTrackerApp());

    // Verify that the app builds without throwing an exception
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
