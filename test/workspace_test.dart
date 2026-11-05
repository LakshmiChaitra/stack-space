import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devboard/state/workspace_store.dart';
import 'package:devboard/models/workspace.dart';
import 'package:devboard/ui/app.dart';

class MemoryPreferences implements SharedPreferencesAsync {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  final Map<String, String> values = {};
  @override
  Future<String?> getString(String key) async => values[key];
  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  test(
    'workspace changes survive reload; deletion cascades and import is atomic',
    () async {
      final prefs = MemoryPreferences();
      final s = WorkspaceStore(preferences: prefs);
      await s.load();
      final p = Project(
        id: 'new',
        name: 'Test app',
        description: 'A test project',
        category: 'Development',
        color: 0xff7962ef,
        deadline: DateTime(2027),
      );
      s.upsertProject(p);
      s.upsertTask(
        WorkTask(
          id: 'test-task',
          projectId: 'new',
          title: 'Ship it',
          assignee: 'm1',
          due: DateTime(2027),
        ),
      );
      s.moveTask(s.tasks.last, 'Done');
      await s.save();
      final loaded = WorkspaceStore(preferences: prefs);
      await loaded.load();
      expect(loaded.progress('new'), 1);
      expect(loaded.tasks.last.title, 'Ship it');
      loaded.removeMember('m1');
      expect(loaded.tasks.last.assignee, '');
      final before = loaded.exportJson();
      final broken = jsonDecode(before);
      broken['tasks'][0]['projectId'] = 'missing';
      expect(
        () => loaded.importJson(jsonEncode(broken)),
        throwsFormatException,
      );
      expect(loaded.exportJson(), before);
      loaded.deleteProject('new');
      expect(loaded.tasks.where((t) => t.projectId == 'new'), isEmpty);
      await loaded.save();
      final restored = WorkspaceStore(preferences: prefs);
      await restored.load();
      expect(restored.projects.any((p) => p.id == 'new'), false);
    },
  );
  test(
    'Indian sample-name migration preserves custom profile and member names',
    () async {
      final prefs = MemoryPreferences();
      final original = WorkspaceStore(preferences: prefs);
      original.seed();
      final old = jsonDecode(original.exportJson());
      old['name'] = 'Kyathi';
      old['projects'][0]['name'] = 'Ship Happens app';
      old['projects'][1]['name'] = 'My custom project';
      old['members'][0]['name'] = 'Alex Morgan';
      old['members'][1]['name'] = 'My custom teammate';
      old['members'][2]['name'] = 'Jordan Lee';
      old['members'][3]['name'] = 'Sam Taylor';
      await prefs.setString('devboard.v1', jsonEncode(old));
      final migrated = WorkspaceStore(preferences: prefs);
      await migrated.load();
      expect(migrated.name, 'Kyathi');
      expect(migrated.projects.first.name, 'Stack Space platform');
      expect(migrated.projects[1].name, 'My custom project');
      expect(migrated.members.map((m) => m.name), [
        'Aarav Sharma',
        'My custom teammate',
        'Arjun Rao',
        'Ananya Iyer',
      ]);
      expect(migrated.tasks.length, original.tasks.length);
      final reloaded = WorkspaceStore(preferences: prefs);
      await reloaded.load();
      expect(reloaded.members.first.name, 'Aarav Sharma');
    },
  );
  for (final dark in [false, true]) {
    for (final size in [
      const Size(1440, 1000),
      const Size(1280, 720),
      const Size(820, 1180),
      const Size(390, 844),
    ]) {
      testWidgets('responsive navigation and task form at $size / dark=$dark', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final font = FontLoader('Manrope')
          ..addFont(rootBundle.load('assets/fonts/Manrope.ttf'));
        await font.load();
        final displayFont = FontLoader('Fraunces')
          ..addFont(rootBundle.load('assets/fonts/Fraunces.ttf'));
        await displayFont.load();
        final store = WorkspaceStore(preferences: MemoryPreferences());
        await store.load();
        store.dark = dark;
        await tester.pumpWidget(StackSpaceApp(store: store));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (size.width < 1050) {
          await tester.tap(find.byTooltip('Open navigation'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Task board').first);
        await tester.pumpAndSettle();
        expect(find.text('From to-do to ta-da.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('New task'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Create task'));
        await tester.tap(find.text('Create task'));
        await tester.pumpAndSettle();
        expect(find.text('This field is required'), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Task title'),
          'Responsive test task',
        );
        await tester.ensureVisible(find.text('Create task'));
        await tester.tap(find.text('Create task'));
        await tester.pumpAndSettle();
        expect(store.tasks.any((t) => t.title == 'Responsive test task'), true);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
