import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devboard/ui/app.dart';
import 'package:devboard/state/workspace_store.dart';

import 'workspace_test.dart' show MemoryPreferences;
import 'planner_test.dart' show loadFont;

Future<WorkspaceStore> workspace() async {
  final store = WorkspaceStore(preferences: MemoryPreferences());
  await store.load();
  store.hasChosenName = true;
  return store;
}

Future<void> pickDate(WidgetTester tester, String date) async {
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.byType(TextFormField),
    ),
    date,
  );
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1280, 900), const Size(390, 844)]) {
    testWidgets('summary cards navigate and filter tasks at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await loadFont();
      final store = await workspace();
      store.dark = size.width < 700;
      for (final title in [
        'Total projects',
        'In progress',
        'Completed tasks',
        'Team members',
      ]) {
        await tester.pumpWidget(StackSpaceApp(key: UniqueKey(), store: store));
        await tester.pumpAndSettle();
        final card = find.byKey(ValueKey('stat-$title'));
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        if (title == 'Total projects') {
          expect(find.text('Your next big thing starts here.'), findsOneWidget);
        } else if (title == 'Team members') {
          expect(
            find.text('Good people. Great possibilities.'),
            findsOneWidget,
          );
        } else {
          final status = title == 'In progress' ? 'In progress' : 'Done';
          expect(find.byKey(ValueKey('status-filter-$status')), findsOneWidget);
          for (final task in store.tasks) {
            expect(
              find.text(task.title),
              task.status == status ? findsOneWidget : findsNothing,
            );
          }
        }
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'project and task dates edit, cancel, and survive reload at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await loadFont();
        final store = await workspace();
        final project = store.projects.first;
        final task = store.forProject(project.id).first;
        await tester.pumpWidget(
          MaterialApp(
            theme: StackSpaceApp(store: store).theme(size.width < 700),
            home: ProjectDetail(store: store, projectId: project.id),
          ),
        );
        await tester.pumpAndSettle();
        final original = project.deadline;
        await tester.tap(find.byKey(ValueKey('project-due-${project.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(project.deadline, original);
        await tester.tap(find.byKey(ValueKey('project-due-${project.id}')));
        await tester.pumpAndSettle();
        await pickDate(tester, '12/20/2028');
        expect(project.deadline, DateTime(2028, 12, 20));
        final due = find.byKey(ValueKey('task-due-${task.id}'));
        await tester.ensureVisible(due);
        await tester.tap(due);
        await tester.pumpAndSettle();
        await pickDate(tester, '12/18/2028');
        expect(task.due, DateTime(2028, 12, 18));
        await store.save();
        final reloaded = WorkspaceStore(preferences: store.prefs);
        await reloaded.load();
        expect(reloaded.projects.first.deadline, DateTime(2028, 12, 20));
        expect(
          reloaded.tasks.singleWhere((t) => t.id == task.id).due,
          DateTime(2028, 12, 18),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
