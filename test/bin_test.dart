import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devboard/state/workspace_store.dart';
import 'package:devboard/ui/app.dart';

import 'workspace_test.dart' show MemoryPreferences;

Future<WorkspaceStore> workspace() async {
  final s = WorkspaceStore(preferences: MemoryPreferences());
  await s.load();
  s.hasChosenName = true;
  return s;
}

void main() {
  test('deleted task survives reload and restores its metadata', () async {
    final s = await workspace();
    final original = s.tasks.first.toJson();
    final item = s.deleteTask('t1')!;
    await s.save();
    expect(s.tasks.any((t) => t.id == 't1'), false);
    final loaded = WorkspaceStore(preferences: s.prefs);
    await loaded.load();
    expect(loaded.bin.single.deletedAt, item.deletedAt);
    expect(loaded.restoreBinItem(item.id), true);
    expect(loaded.tasks.singleWhere((t) => t.id == 't1').toJson(), original);
    expect(loaded.bin, isEmpty);
    await loaded.save();
    final saved = WorkspaceStore(preferences: s.prefs);
    await saved.load();
    expect(saved.bin, isEmpty);
    expect(saved.tasks.any((t) => t.id == 't1'), true);
  });
  test(
    'restoring a task restores its missing parent and grouped project tasks',
    () async {
      final s = await workspace();
      final task = s.deleteTask('t1')!;
      final project = s.deleteProject('p1')!;
      expect(project.tasks.length, 2);
      expect(s.bin.length, 2);
      expect(s.projects.any((p) => p.id == 'p1'), false);
      expect(s.restoreBinItem(task.id), true);
      expect(s.bin, isEmpty);
      expect(s.forProject('p1').length, 3);
      expect(s.tasks.singleWhere((t) => t.id == 't1').status, 'In progress');
      expect(s.progress('p1'), closeTo(1 / 3, .00001));
    },
  );
  test('permanent project deletion clears related Bin tasks and prevents stale Undo', () async {
    final s = await workspace();
    final task = s.deleteTask('t1')!;
    final project = s.deleteProject('p1')!;
    final remaining = s.tasks.map((t) => t.id).toSet();
    s.permanentlyDeleteBinItem(project.id);
    expect(s.bin, isEmpty);
    expect(s.restoreBinItem(project.id), false);
    expect(s.restoreBinItem(task.id), false);
    expect(s.tasks.map((t) => t.id).toSet(), remaining);
    await s.save();
    final loaded = WorkspaceStore(preferences: s.prefs);
    await loaded.load();
    expect(loaded.bin, isEmpty);
    expect(loaded.projects.any((p) => p.id == 'p1'), false);
  });
  test('empty Bin preserves all active workspace data', () async {
    final s = await workspace();
    s.deleteTask('t1');
    final tasks = s.tasks.map((t) => t.toJson()).toList(),
        projects = s.projects.map((p) => p.toJson()).toList(),
        members = s.members.map((m) => m.toJson()).toList();
    s.emptyBin();
    expect(s.bin, isEmpty);
    expect(s.tasks.map((t) => t.toJson()).toList(), tasks);
    expect(s.projects.map((p) => p.toJson()).toList(), projects);
    expect(s.members.map((m) => m.toJson()).toList(), members);
  });
  test(
    'backup includes Bin and rejects active/deleted task conflicts atomically',
    () async {
      final s = await workspace();
      final item = s.deleteTask('t1')!;
      final original = s.exportJson();
      final backup = jsonDecode(original);
      backup['tasks'].add(item.tasks.single.toJson());
      expect(() => s.importJson(jsonEncode(backup)), throwsFormatException);
      expect(s.exportJson(), original);
      final restored = WorkspaceStore(preferences: MemoryPreferences());
      restored.importJson(original);
      expect(restored.bin.single.tasks.single.id, 't1');
      expect(restored.tasks.any((t) => t.id == 't1'), false);
    },
  );
  test('legacy backups without Bin remain compatible', () async {
    final s = await workspace();
    final old = jsonDecode(s.exportJson())..remove('bin');
    await s.prefs.setString('devboard.v1', jsonEncode(old));
    final loaded = WorkspaceStore(preferences: s.prefs);
    await loaded.load();
    expect(loaded.bin, isEmpty);
    expect(loaded.tasks.length, 8);
    expect(loaded.storageError, isNull);
  });
  for (final dark in [false, true]) {
    for (final size in [const Size(1280, 900), const Size(390, 844)]) {
      testWidgets(
        'Bin restore and permanent delete confirm at $size / dark=$dark',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await (FontLoader(
            'Manrope',
          )..addFont(rootBundle.load('assets/fonts/Manrope.ttf'))).load();
          final s = await workspace();
          final task = s.deleteTask('t1')!, project = s.deleteProject('p1')!;
          await tester.pumpWidget(
            MaterialApp(
              theme: StackSpaceApp(store: s).theme(dark),
              home: Scaffold(body: BinPage(store: s)),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('Restore project & task'), findsOneWidget);
          final restore = find.byKey(ValueKey('restore-bin-${project.id}'));
          await tester.ensureVisible(restore);
          await tester.tap(restore);
          await tester.pumpAndSettle();
          expect(s.projects.any((p) => p.id == 'p1'), true);
          expect(s.forProject('p1').length, 2);
          expect(s.bin.single.id, task.id);
          await tester.ensureVisible(find.text('Empty Bin'));
          await tester.tap(find.text('Empty Bin'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          expect(s.bin.length, 1);
          final purge = find.byKey(ValueKey('purge-bin-${task.id}'));
          await tester.ensureVisible(purge);
          await tester.tap(purge);
          await tester.pumpAndSettle();
          expect(s.bin.length, 1);
          await tester.tap(find.text('Confirm'));
          await tester.pumpAndSettle();
          expect(s.bin, isEmpty);
          expect(s.forProject('p1').length, 2);
          expect(find.text('All clear.'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
