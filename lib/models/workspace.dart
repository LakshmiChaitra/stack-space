class Project {
  final String id;
  String name, description, category, repository;
  int color;
  DateTime deadline;
  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.color,
    required this.deadline,
    this.repository = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'color': color,
    'deadline': deadline.toIso8601String(),
    'repository': repository,
  };
  factory Project.fromJson(Map<String, dynamic> j) => Project(
    id: j['id'],
    name: j['name'],
    description: j['description'],
    category: j['category'],
    color: j['color'],
    deadline: DateTime.parse(j['deadline']),
    repository: j['repository'] ?? '',
  );
}

class WorkTask {
  final String id;
  String projectId, title, description, status, priority, assignee;
  DateTime due;
  WorkTask({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = 'To do',
    this.priority = 'Medium',
    required this.assignee,
    required this.due,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'assignee': assignee,
    'due': due.toIso8601String(),
  };
  factory WorkTask.fromJson(Map<String, dynamic> j) => WorkTask(
    id: j['id'],
    projectId: j['projectId'],
    title: j['title'],
    description: j['description'],
    status: j['status'],
    priority: j['priority'],
    assignee: j['assignee'],
    due: DateTime.parse(j['due']),
  );
}

class Member {
  final String id;
  String name, role;
  Member(this.id, this.name, this.role);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};
  factory Member.fromJson(Map<String, dynamic> j) =>
      Member(j['id'], j['name'], j['role']);
}

class BinItem {
  final String id;
  final bool isProject;
  final Project project;
  final List<WorkTask> tasks;
  final DateTime deletedAt;
  BinItem({
    required this.id,
    required this.isProject,
    required this.project,
    required this.tasks,
    required this.deletedAt,
  });
  String get title => isProject ? project.name : tasks.single.title;
  Map<String, dynamic> toJson() => {
    'id': id,
    'isProject': isProject,
    'project': project.toJson(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'deletedAt': deletedAt.toIso8601String(),
  };
  factory BinItem.fromJson(Map<String, dynamic> j) {
    final project = Project.fromJson(j['project']);
    final tasks = (j['tasks'] as List)
        .map((t) => WorkTask.fromJson(t))
        .toList();
    final isProject = j['isProject'] as bool;
    if ((!isProject && tasks.length != 1) ||
        tasks.any(
          (t) =>
              t.projectId != project.id ||
              !['To do', 'In progress', 'Done'].contains(t.status) ||
              !['High', 'Medium', 'Low'].contains(t.priority),
        )) {
      throw const FormatException('Invalid Bin item');
    }
    return BinItem(
      id: j['id'],
      isProject: isProject,
      project: project,
      tasks: tasks,
      deletedAt: DateTime.parse(j['deletedAt']),
    );
  }
}
