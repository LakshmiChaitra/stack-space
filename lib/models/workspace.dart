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
