import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_world/main.dart';

void main() {
  testWidgets('LanguagePage - Start recording', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LanguagePage()));

    final startRecordingButtonFinder = find.text('Aufnahme starten');
    expect(startRecordingButtonFinder, findsOneWidget);

    await tester.tap(startRecordingButtonFinder);
    await tester.pump();

    final pauseButtonFinder = find.text('Pause');
    expect(pauseButtonFinder, findsOneWidget);
  });

  testWidgets('LanguagePage - Stop recording', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LanguagePage()));

    final startRecordingButtonFinder = find.text('Aufnahme starten');
    expect(startRecordingButtonFinder, findsOneWidget);

    await tester.tap(startRecordingButtonFinder);
    await tester.pump();

    final stopRecordingButtonFinder = find.text('Aufnahme beenden und senden');
    expect(stopRecordingButtonFinder, findsOneWidget);

    await tester.tap(stopRecordingButtonFinder);
    await tester.pump();

    final startRecordingButtonFinderAfterStop = find.text('Aufnahme starten');
    expect(startRecordingButtonFinderAfterStop, findsOneWidget);
  });
}
