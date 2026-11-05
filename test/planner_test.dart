import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devboard/ui/app.dart';
import 'package:devboard/state/workspace_store.dart';
import 'package:devboard/models/workspace.dart';

import 'workspace_test.dart' show MemoryPreferences;

Future<void> loadFont() async {
  await (FontLoader(
    'Manrope',
  )..addFont(rootBundle.load('assets/fonts/Manrope.ttf'))).load();
}

Future<WorkspaceStore> setup() async {
  final s = WorkspaceStore(preferences: MemoryPreferences());
  await s.load();
  s.hasChosenName = true;
  s.tasks.clear();
  return s;
}

Widget planner(WorkspaceStore s, {bool dark = false}) => MaterialApp(
  theme: StackSpaceApp(store: s).theme(dark),
  home: Scaffold(
    body: PlannerPage(store: s, initialDate: DateTime(2028, 1, 31)),
  ),
);
void main() {
  for (final dark in [false, true]) {
    for (final size in [
      const Size(1280, 1000),
      const Size(820, 1180),
      const Size(390, 844),
    ]) {
      testWidgets(
        'planner shares dated tasks, completion and day view at $size / dark=$dark',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await loadFont();
          final s = await setup();
          s.upsertTask(
            WorkTask(
              id: 'fixture',
              projectId: 'p1',
              title: 'Review the sprint',
              assignee: 'm1',
              due: DateTime(2028, 1, 31, 16),
              status: 'In progress',
            ),
          );
          await tester.pumpWidget(planner(s, dark: dark));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final circle = find.byKey(const ValueKey('planner-check-fixture'));
          await tester.ensureVisible(circle);
          await tester.tap(circle);
          await tester.pumpAndSettle();
          expect(s.tasks.first.status, 'Done');
          expect(s.progress('p1'), 1);
          await tester.tap(circle);
          await tester.pumpAndSettle();
          expect(s.tasks.first.status, 'To do');
          final entry = find.byKey(const ValueKey('planner-quick-task'));
          await tester.ensureVisible(entry);
          await tester.enterText(entry, 'Plan study session');
          await tester.tap(find.byTooltip('Add task to selected day'));
          await tester.pumpAndSettle();
          final added = s.tasks.singleWhere(
            (t) => t.title == 'Plan study session',
          );
          expect(added.due, DateTime(2028, 1, 31));
          expect(added.projectId, 'p1');
          await s.save();
          final saved = WorkspaceStore(preferences: s.prefs);
          await saved.load();
          expect(
            saved.tasks.any(
              (t) =>
                  t.title == 'Plan study session' &&
                  t.due == DateTime(2028, 1, 31),
            ),
            true,
          );
          await tester.ensureVisible(find.text('Day'));
          await tester.tap(find.text('Day'));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('planner-date-2028-1-31')),
            findsNothing,
          );
          expect(find.text('Plan study session'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'month navigation clamps leap day and selecting a date opens its tasks',
    (tester) async {
      await loadFont();
      final s = await setup();
      s.upsertTask(
        WorkTask(
          id: 'leap',
          projectId: 'p1',
          title: 'Leap day plan',
          assignee: '',
          due: DateTime(2028, 2, 29),
        ),
      );
      await tester.pumpWidget(planner(s));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('February 2028'), findsOneWidget);
      expect(find.text('29 February 2028'), findsOneWidget);
      expect(find.text('Leap day plan'), findsWidgets);
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('planner-date-2028-1-25')),
      );
      await tester.tap(find.byKey(const ValueKey('planner-date-2028-1-25')));
      await tester.pumpAndSettle();
      expect(find.text('25 January 2028'), findsOneWidget);
      expect(find.text('Leap day plan'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'project card delete confirms and Undo restores project and tasks',
    (tester) async {
      await loadFont();
      final s = await setup();
      s.upsertTask(
        WorkTask(
          id: 'restore-me',
          projectId: 'p1',
          title: 'Keep this task',
          assignee: 'm1',
          due: DateTime(2028),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: StackSpaceApp(store: s).theme(false),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 296,
                child: ProjectCard(
                  project: s.projects.first,
                  store: s,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final trash = find.byTooltip('Delete Stack Space platform');
      await tester.tap(trash);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(s.projects.any((p) => p.id == 'p1'), true);
      await tester.tap(trash);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(s.projects.any((p) => p.id == 'p1'), false);
      expect(s.tasks, isEmpty);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(s.projects.any((p) => p.id == 'p1'), true);
      expect(s.tasks.single.id, 'restore-me');
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'restored tasks persist and removed team members stay unassigned',
    () async {
      final s = await setup();
      final p = s.projects.first;
      final t = WorkTask(
        id: 'restored',
        projectId: p.id,
        title: 'Saved task',
        assignee: 'm1',
        due: DateTime(2028),
      );
      s.upsertTask(t);
      s.deleteProject(p.id);
      s.removeMember('m1');
      s.restoreProject(p, [t]);
      await s.save();
      final reloaded = WorkspaceStore(preferences: s.prefs);
      await reloaded.load();
      expect(reloaded.tasks.single.assignee, '');
      expect(reloaded.projects.any((p) => p.id == 'p1'), true);
    },
  );
}
