import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workspace.dart';

class WorkspaceStore extends ChangeNotifier {
  final SharedPreferencesAsync prefs;
  WorkspaceStore({SharedPreferencesAsync? preferences})
    : prefs = preferences ?? SharedPreferencesAsync();
  List<Project> projects = [];
  List<WorkTask> tasks = [];
  List<Member> members = [];
  List<String> activity = [];
  String name = 'Chaitra', workspace = 'Dev collective';
  bool dark = false;
  bool hasChosenName = false;
  String? storageError;
  Future<void> _writes = Future.value();
  void chooseName(String value) {
    name = value.trim().isEmpty ? 'Chaitra' : value.trim();
    hasChosenName = true;
    notifyListeners();
    save();
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();
  Future<void> load() async {
    try {
      final raw = await prefs.getString('devboard.v1');
      if (raw == null) {
        seed();
        await save();
        return;
      }
      final j = jsonDecode(raw) as Map<String, dynamic>;
      projects = (j['projects'] as List)
          .map((x) => Project.fromJson(x))
          .toList();
      tasks = (j['tasks'] as List).map((x) => WorkTask.fromJson(x)).toList();
      members = (j['members'] as List).map((x) => Member.fromJson(x)).toList();
      activity = List<String>.from(j['activity']);
      name = j['name'];
      hasChosenName =
          j['hasChosenName'] as bool? ??
          !['Alex', 'Aarav', 'Chaitra'].contains(name);
      if (!hasChosenName && ['Alex', 'Aarav'].contains(name)) {
        name = 'Chaitra';
      }
      workspace = j['workspace'];
      dark = j['dark'];
      var migrated = false;
      const sampleNames = {
        'm1': ['Alex Morgan', 'Aarav Sharma'],
        'm2': ['Priya Shah', 'Priya Reddy'],
        'm3': ['Jordan Lee', 'Arjun Rao'],
        'm4': ['Sam Taylor', 'Ananya Iyer'],
      };
      for (final member in members) {
        final replacement = sampleNames[member.id];
        if (replacement != null && member.name == replacement.first) {
          member.name = replacement.last;
          migrated = true;
        }
      }
      if (name == 'Alex') {
        name = 'Chaitra';
        migrated = true;
      }
      for (final project in projects) {
        if (project.id == 'p1' &&
            (project.name == 'DevBoard platform' ||
                project.name == 'Ship Happens app' ||
                project.name == 'Taskonaut platform')) {
          project.name = 'Stack Space platform';
          migrated = true;
        }
      }
      final originalActivity = activity.join('\n');
      activity = activity
          .map(
            (event) => event
                .replaceAll(
                  'Alex created DevBoard platform',
                  'Aarav created Stack Space platform',
                )
                .replaceAll(
                  'Aarav created DevBoard platform',
                  'Aarav created Stack Space platform',
                )
                .replaceAll(
                  'Aarav created Ship Happens app',
                  'Aarav created Stack Space platform',
                )
                .replaceAll(
                  'Aarav created Taskonaut platform',
                  'Aarav created Stack Space platform',
                )
                .replaceAll(
                  'Sam completed “Map the core user journeys”',
                  'Ananya completed “Map the core user journeys”',
                ),
          )
          .toList();
      if (migrated || activity.join('\n') != originalActivity) {
        await save();
      }
    } catch (_) {
      storageError = 'Saved workspace could not be loaded. Please export any changes before closing.';
      seed();
    }
    notifyListeners();
  }

  void seed() {
    final now = DateTime.now();
    members = [
      Member('m1', 'Aarav Sharma', 'Frontend developer'),
      Member('m2', 'Priya Reddy', 'UI / UX designer'),
      Member('m3', 'Arjun Rao', 'Backend developer'),
      Member('m4', 'Ananya Iyer', 'Developer'),
    ];
    projects = [
      Project(
        id: 'p1',
        name: 'Stack Space platform',
        description: 'A better space to build things together.',
        category: 'Development',
        color: 0xff7962ef,
        deadline: now.add(const Duration(days: 12)),
        repository: 'flutter/flutter',
      ),
      Project(
        id: 'p2',
        name: 'Orbit design system',
        description: 'Thoughtful components. One consistent experience.',
        category: 'Design',
        color: 0xffeb9f54,
        deadline: now.add(const Duration(days: 8)),
      ),
      Project(
        id: 'p3',
        name: 'Campus connect',
        description: 'Bringing our student community a little closer.',
        category: 'Mobile app',
        color: 0xff55a99a,
        deadline: now.add(const Duration(days: 20)),
      ),
    ];
    tasks = [
      WorkTask(
        id: 't1',
        projectId: 'p1',
        title: 'Build the dashboard layout',
        description:
            'Create responsive layouts for desktop, tablet, and mobile.',
        status: 'In progress',
        priority: 'High',
        assignee: 'm1',
        due: now,
      ),
      WorkTask(
        id: 't2',
        projectId: 'p2',
        title: 'Design the component library',
        status: 'In progress',
        priority: 'Medium',
        assignee: 'm2',
        due: now.add(const Duration(days: 1)),
      ),
      WorkTask(
        id: 't3',
        projectId: 'p1',
        title: 'Connect repository insights',
        status: 'To do',
        priority: 'High',
        assignee: 'm3',
        due: now.add(const Duration(days: 2)),
      ),
      WorkTask(
        id: 't4',
        projectId: 'p3',
        title: 'Sketch the onboarding flow',
        status: 'To do',
        priority: 'Low',
        assignee: 'm2',
        due: now.add(const Duration(days: 3)),
      ),
      WorkTask(
        id: 't5',
        projectId: 'p1',
        title: 'Set up the project structure',
        status: 'Done',
        assignee: 'm1',
        due: now.subtract(const Duration(days: 2)),
      ),
      WorkTask(
        id: 't6',
        projectId: 'p2',
        title: 'Define colors and typography',
        status: 'Done',
        assignee: 'm2',
        due: now.subtract(const Duration(days: 1)),
      ),
      WorkTask(
        id: 't7',
        projectId: 'p3',
        title: 'Map the core user journeys',
        status: 'Done',
        assignee: 'm4',
        due: now,
      ),
      WorkTask(
        id: 't8',
        projectId: 'p3',
        title: 'Build the student profile',
        status: 'In progress',
        assignee: 'm4',
        due: now.add(const Duration(days: 5)),
      ),
    ];
    activity = [
      'Priya completed “Define colors and typography”',
      'Aarav created Stack Space platform',
      'Ananya completed “Map the core user journeys”',
    ];
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert({
    'version': 1,
    'projects': projects.map((p) => p.toJson()).toList(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'members': members.map((m) => m.toJson()).toList(),
    'activity': activity,
    'name': name,
    'workspace': workspace,
    'dark': dark,
    'hasChosenName': hasChosenName,
  });
  Future<void> save() {
    final snapshot = exportJson();
    _writes = _writes.then((_) async {
      try {
        await prefs.setString('devboard.v1', snapshot);
        storageError = null;
      } catch (_) {
        storageError = 'Could not save changes on this device. Export a backup from Settings.';
      }
      notifyListeners();
    });
    return _writes;
  }

  void changed(String event) {
    activity.insert(0, event);
    if (activity.length > 30) activity.removeLast();
    notifyListeners();
    save();
  }

  List<WorkTask> forProject(String id) =>
      tasks.where((t) => t.projectId == id).toList();
  double progress(String id) {
    final list = forProject(id);
    return list.isEmpty
        ? 0
        : list.where((t) => t.status == 'Done').length / list.length;
  }

  void upsertProject(Project p) {
    final i = projects.indexWhere((x) => x.id == p.id);
    if (i < 0) {
      projects.add(p);
    } else {
      projects[i] = p;
    }
    changed('${i < 0 ? 'Created' : 'Updated'} ${p.name}');
  }

  void deleteProject(String id) {
    projects.removeWhere((p) => p.id == id);
    tasks.removeWhere((t) => t.projectId == id);
    changed('Removed a project and its tasks');
  }

  void upsertTask(WorkTask t) {
    final i = tasks.indexWhere((x) => x.id == t.id);
    if (i < 0) {
      tasks.add(t);
    } else {
      tasks[i] = t;
    }
    changed('${i < 0 ? 'Created' : 'Updated'} “${t.title}”');
  }

  void moveTask(WorkTask t, String status) {
    t.status = status;
    changed('Moved “${t.title}” to $status');
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    changed('Removed a task');
  }

  void addMember(Member m) {
    members.add(m);
    changed('Added ${m.name} to the team directory');
  }

  void removeMember(String id) {
    members.removeWhere((m) => m.id == id);
    for (final t in tasks) {
      if (t.assignee == id) t.assignee = '';
    }
    changed('Removed a team member');
  }

  void importJson(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final ps = (j['projects'] as List).map((x) => Project.fromJson(x)).toList();
    final ts = (j['tasks'] as List).map((x) => WorkTask.fromJson(x)).toList();
    final ms = (j['members'] as List).map((x) => Member.fromJson(x)).toList();
    if (ps.map((p) => p.id).toSet().length != ps.length ||
        ts.map((t) => t.id).toSet().length != ts.length ||
        ms.map((m) => m.id).toSet().length != ms.length ||
        ts.any(
          (t) =>
              !ps.any((p) => p.id == t.projectId) ||
              !['To do', 'In progress', 'Done'].contains(t.status) ||
              !['High', 'Medium', 'Low'].contains(t.priority) ||
              (t.assignee.isNotEmpty && !ms.any((m) => m.id == t.assignee)),
        )) {
      throw const FormatException('Invalid references');
    }
    final importedName = j['name'] as String;
    final importedWorkspace = j['workspace'] as String;
    final importedDark = j['dark'] as bool;
    final importedChosenName = j['hasChosenName'] as bool? ?? true;
    final importedActivity = List<String>.from(j['activity']);
    projects = ps;
    tasks = ts;
    members = ms;
    name = importedName;
    workspace = importedWorkspace;
    dark = importedDark;
    hasChosenName = importedChosenName;
    activity = importedActivity;
    changed('Restored workspace from backup');
  }
}
