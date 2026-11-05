import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devboard/state/workspace_store.dart';
import 'package:devboard/ui/app.dart';

import 'workspace_test.dart' show MemoryPreferences;

void main() {
  test(
    'choice survives reload and legacy custom names are preserved',
    () async {
      final prefs = MemoryPreferences();
      final store = WorkspaceStore(preferences: prefs);
      await store.load();
      expect(store.name, 'Chaitra');
      expect(store.hasChosenName, false);
      store.chooseName('  Chaitra  ');
      await store.save();
      final loaded = WorkspaceStore(preferences: prefs);
      await loaded.load();
      expect(loaded.name, 'Chaitra');
      expect(loaded.hasChosenName, true);
      final old = jsonDecode(loaded.exportJson())..remove('hasChosenName');
      old['name'] = 'Kyathi';
      await prefs.setString('devboard.v1', jsonEncode(old));
      final custom = WorkspaceStore(preferences: prefs);
      await custom.load();
      expect(custom.name, 'Kyathi');
      expect(custom.hasChosenName, true);
      old['name'] = 'Aarav';
      await prefs.setString('devboard.v1', jsonEncode(old));
      final legacy = WorkspaceStore(preferences: prefs);
      await legacy.load();
      expect(legacy.name, 'Chaitra');
      expect(legacy.hasChosenName, false);
    },
  );
  for (final dark in [false, true]) {
    testWidgets('first visit validation and remembered name / dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await (FontLoader(
        'Manrope',
      )..addFont(rootBundle.load('assets/fonts/Manrope.ttf'))).load();
      final store = WorkspaceStore(preferences: MemoryPreferences());
      await store.load();
      store.dark = dark;
      await tester.pumpWidget(StackSpaceApp(store: store));
      await tester.pumpAndSettle();
      expect(find.text('What should we call you?'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Let’s build'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your name'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '  Chaitra  ');
      await tester.tap(find.text('Let’s build'));
      await tester.pumpAndSettle();
      expect(store.name, 'Chaitra');
      expect(store.hasChosenName, true);
      expect(find.text('Welcome back, Chaitra.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('fallback enters workspace as Chaitra', (tester) async {
    final store = WorkspaceStore(preferences: MemoryPreferences());
    await store.load();
    await tester.pumpWidget(StackSpaceApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as Chaitra'));
    await tester.pumpAndSettle();
    expect(store.name, 'Chaitra');
    expect(store.hasChosenName, true);
  });
}
