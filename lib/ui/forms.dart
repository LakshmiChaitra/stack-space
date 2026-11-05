part of 'app.dart';

String? requiredText(String? v) =>
    v == null || v.trim().isEmpty ? 'This field is required' : null;
Future<bool> confirm(
  BuildContext context,
  String title,
  String description,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
    false;
Widget formField(
  String label,
  TextEditingController controller, {
  int lines = 1,
  String? hint,
  String? Function(String?)? validator,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: TextFormField(
    controller: controller,
    maxLines: lines,
    maxLength: lines > 1 ? 400 : 100,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      counterText: '',
    ),
    validator: validator ?? requiredText,
  ),
);
Future<void> projectForm(
  BuildContext context,
  WorkspaceStore s, {
  Project? existing,
}) async {
  final key = GlobalKey<FormState>();
  final name = TextEditingController(text: existing?.name);
  final description = TextEditingController(text: existing?.description);
  final repo = TextEditingController(text: existing?.repository);
  String category = existing?.category ?? 'Development';
  int color = existing?.color ?? violet.toARGB32();
  DateTime date =
      existing?.deadline ?? DateTime.now().add(const Duration(days: 14));
  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null
                              ? 'A new beginning.'
                              : 'Project details',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -.6,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Give your next big idea a home.',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 25),
                  formField('Project name', name),
                  formField('Description', description, lines: 3),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items:
                        [
                              'Development',
                              'Design',
                              'Mobile app',
                              'Research',
                              'Other',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                    onChanged: (v) => category = v!,
                  ),
                  const SizedBox(height: 18),
                  formField(
                    'Public GitHub repository (optional)',
                    repo,
                    hint: 'owner/repository',
                    validator: (v) =>
                        v == null ||
                            v.trim().isEmpty ||
                            RegExp(r'^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$')
                                .hasMatch(v.trim())
                        ? null
                        : 'Use owner/repository, e.g. flutter/flutter',
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (selected != null) update(() => date = selected);
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text('Target: ${dateLabel(date)}, ${date.year}'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Project color',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children:
                        [
                              0xff7962ef,
                              0xffeb9f54,
                              0xff55a99a,
                              0xff6e99d5,
                              0xffd5799f,
                            ]
                            .map(
                              (c) => Semantics(
                                label: 'Project color ${c.toRadixString(16)}',
                                selected: color == c,
                                button: true,
                                child: InkWell(
                                  onTap: () => update(() => color = c),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 33,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      color: Color(c),
                                      shape: BoxShape.circle,
                                    ),
                                    child: color == c
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          if (!key.currentState!.validate()) return;
                          s.upsertProject(
                            Project(
                              id: existing?.id ?? s.newId(),
                              name: name.text.trim(),
                              description: description.text.trim(),
                              category: category,
                              color: color,
                              deadline: date,
                              repository: repo.text.trim(),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          existing == null ? 'Create project' : 'Save changes',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  // Controllers are disposed after the dialog route's exit animation.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  name.dispose();
  description.dispose();
  repo.dispose();
}

Future<void> taskForm(
  BuildContext context,
  WorkspaceStore s, {
  WorkTask? existing,
  String? projectId,
  String status = 'To do',
}) async {
  if (s.projects.isEmpty) return;
  final key = GlobalKey<FormState>();
  final title = TextEditingController(text: existing?.title);
  final description = TextEditingController(text: existing?.description);
  String project = existing?.projectId ?? projectId ?? s.projects.first.id;
  String state = existing?.status ?? status;
  String priority = existing?.priority ?? 'Medium';
  String assignee = existing?.assignee ?? '';
  DateTime due = existing?.due ?? DateTime.now().add(const Duration(days: 1));
  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null
                              ? 'One step closer.'
                              : 'Task details',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  formField('Task title', title),
                  formField(
                    'Description (optional)',
                    description,
                    lines: 3,
                    validator: (_) => null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: project,
                    decoration: const InputDecoration(labelText: 'Project'),
                    isExpanded: true,
                    items: s.projects
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => project = v!,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: state,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: statuses
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    v,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => state = v!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items: priorities
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    v,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => priority = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: assignee,
                    decoration: const InputDecoration(labelText: 'Assignee'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Unassigned'),
                      ),
                      ...s.members.map(
                        (m) =>
                            DropdownMenuItem(value: m.id, child: Text(m.name)),
                      ),
                    ],
                    onChanged: (v) => assignee = v!,
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: due,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) update(() => due = d);
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text('Due: ${dateLabel(due)}, ${due.year}'),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      if (existing != null)
                        TextButton(
                          onPressed: () async {
                            if (await confirm(
                              context,
                              'Delete this task?',
                              'This task will be removed from the workspace.',
                            )) {
                              s.deleteTask(existing.id);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Delete task',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          if (!key.currentState!.validate()) return;
                          s.upsertTask(
                            WorkTask(
                              id: existing?.id ?? s.newId(),
                              projectId: project,
                              title: title.text.trim(),
                              description: description.text.trim(),
                              status: state,
                              priority: priority,
                              assignee: assignee,
                              due: due,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          existing == null ? 'Create task' : 'Save changes',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  title.dispose();
  description.dispose();
}

Future<void> memberForm(BuildContext context, WorkspaceStore s) async {
  final key = GlobalKey<FormState>();
  final name = TextEditingController();
  final role = TextEditingController();
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Build your team.'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add a person to your local team directory.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 22),
              formField('Full name', name),
              formField('Role', role),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!key.currentState!.validate()) return;
            s.addMember(Member(s.newId(), name.text.trim(), role.text.trim()));
            Navigator.pop(context);
          },
          child: const Text('Add member'),
        ),
      ],
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  name.dispose();
  role.dispose();
}

Future<void> backupDialog(BuildContext context, WorkspaceStore s) async {
  final raw = s.exportJson();
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Your workspace, backed up.'),
      content: SizedBox(
        width: 600,
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copy this JSON and save it as stack-space-backup.json. Restore it here whenever you need.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  raw,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: raw));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup copied. Save it in a .json file.'),
                ),
              );
            }
          },
          icon: const Icon(Icons.copy, size: 17),
          label: const Text('Copy JSON'),
        ),
      ],
    ),
  );
}

Future<void> importDialog(BuildContext context, WorkspaceStore s) async {
  final controller = TextEditingController();
  String? error;
  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => AlertDialog(
        title: const Text('Restore a workspace'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste your exported JSON below. Restoring replaces your current workspace, including projects and tasks.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.6),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Paste backup JSON',
                  errorText: error,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                jsonDecode(controller.text);
              } catch (_) {
                update(
                  () => error = 'Enter valid JSON from a Stack Space backup.',
                );
                return;
              }
              if (!await confirm(
                context,
                'Replace current workspace?',
                'Export your current data first if you need to keep it.',
              )) {
                return;
              }
              try {
                s.importJson(controller.text);
                if (context.mounted) Navigator.pop(context);
              } catch (_) {
                update(
                  () => error =
                      'Invalid backup. Check its fields and references.',
                );
              }
            },
            child: const Text('Restore backup'),
          ),
        ],
      ),
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  controller.dispose();
}

class ProfileSettings extends StatefulWidget {
  final WorkspaceStore store;
  const ProfileSettings({super.key, required this.store});
  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final key = GlobalKey<FormState>();
  late TextEditingController name, workspace;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.store.name);
    workspace = TextEditingController(text: widget.store.workspace);
  }

  @override
  void dispose() {
    name.dispose();
    workspace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Panel(
    child: Form(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Workspace profile'),
          formField('Your name', name),
          formField('Workspace name', workspace),
          FilledButton(
            onPressed: () {
              if (!key.currentState!.validate()) return;
              widget.store.name = name.text.trim();
              widget.store.workspace = workspace.text.trim();
              widget.store.changed('Updated workspace profile');
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Profile saved')));
            },
            child: const Text('Save profile'),
          ),
        ],
      ),
    ),
  );
}
