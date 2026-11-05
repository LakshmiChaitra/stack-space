part of 'app.dart';

extension _WorkspacePages on _WorkspaceShellState {
  Widget pageScroll(List<Widget> children) => LayoutBuilder(
    builder: (context, c) => SingleChildScrollView(
      padding: EdgeInsets.all(c.maxWidth > 800 ? 34 : 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ),
  );
  Widget heading(String title, String subtitle, {Widget? action}) =>
      LayoutBuilder(
        builder: (context, c) => Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 16,
            children: [
              SizedBox(
                width: c.maxWidth > 700
                    ? c.maxWidth - (action == null ? 0 : 200)
                    : c.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              ?action,
            ],
          ),
        ),
      );
  Widget overview() {
    final done = s.tasks.where((t) => t.status == 'Done').length;
    final active = s.tasks.where((t) => t.status == 'In progress').length;
    final pending =
        s.tasks
            .where(
              (t) =>
                  t.status != 'Done' && t.title.toLowerCase().contains(query),
            )
            .toList()
          ..sort((a, b) => a.due.compareTo(b.due));
    final projects = s.projects
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
    return pageScroll([
      StudioGreeting(name: s.name),
      const SizedBox(height: 24),
      StudioHero(
        onCreate: () => projectForm(context, s),
        completed: done,
        total: s.tasks.length,
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth < 600 ? 2 : 4;
          final cards = [
            StatCard(
              title: 'Total projects',
              value: '${s.projects.length}'.padLeft(2, '0'),
              caption: 'Ideas taking shape',
              icon: Icons.folder_outlined,
              color: violet,
            ),
            StatCard(
              title: 'In progress',
              value: '$active'.padLeft(2, '0'),
              caption: 'Moving things forward',
              icon: Icons.timelapse_rounded,
              color: const Color(0xffd49e4d),
            ),
            StatCard(
              title: 'Completed tasks',
              value: '$done'.padLeft(2, '0'),
              caption: 'Little wins, big progress',
              icon: Icons.task_alt_rounded,
              color: const Color(0xff55a99a),
            ),
            StatCard(
              title: 'Team members',
              value: '${s.members.length}'.padLeft(2, '0'),
              caption: 'Better when we build together',
              icon: Icons.people_outline,
              color: const Color(0xff7e9bcd),
            ),
          ];
          return GridView.count(
            crossAxisCount: cols,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 164,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cards,
          );
        },
      ),
      const SizedBox(height: 28),
      SectionTitle(
        'The things you’re building',
        action: 'All projects',
        onTap: () => navigate('Projects'),
      ),
      if (projects.isEmpty)
        const Panel(
          child: EmptyView(
            'A fresh canvas',
            'Create a project to bring your next idea to life.',
          ),
        )
      else
        projectGrid(projects.take(3).toList()),
      const SizedBox(height: 28),
      LayoutBuilder(
        builder: (context, c) {
          final left = Panel(
            child: Column(
              children: [
                SectionTitle(
                  'Up next',
                  action: 'Open task board',
                  onTap: () => navigate('Task board'),
                ),
                if (pending.isEmpty)
                  const EmptyView(
                    'All caught up',
                    'Enjoy the quiet, or start something new.',
                  ),
                ...pending
                    .take(4)
                    .map(
                      (t) => TaskTile(
                        task: t,
                        store: s,
                        onTap: () => taskForm(context, s, existing: t),
                      ),
                    ),
              ],
            ),
          );
          final right = Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workspace progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 17),
                Center(
                  child: ProgressRing(
                    value: s.tasks.isEmpty ? 0 : done / s.tasks.length,
                    completed: done,
                    total: s.tasks.length,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '$done of ${s.tasks.length} tasks complete',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.circle, size: 7, color: violet),
                    const SizedBox(width: 6),
                    Text(
                      '$active in progress',
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.circle, size: 7, color: Color(0xffdcd7f7)),
                    const SizedBox(width: 6),
                    Text(
                      '${s.tasks.where((t) => t.status == 'To do').length} to do',
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          );
          return c.maxWidth > 850
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: left),
                    const SizedBox(width: 22),
                    Expanded(child: right),
                  ],
                )
              : Column(children: [left, const SizedBox(height: 20), right]);
        },
      ),
      const SizedBox(height: 28),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Recent activity'),
            ...s.activity
                .take(3)
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: violet.withValues(alpha: .08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history,
                            size: 15,
                            color: violet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.value,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          e.key == 0 ? 'Latest' : 'Earlier',
                          style: const TextStyle(color: muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      const Center(
        child: Text(
          'Made for the way you build. ✦',
          style: TextStyle(fontSize: 10, color: muted),
        ),
      ),
    ]);
  }

  Widget projectGrid(List<Project> list) => LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth > 950
          ? 3
          : c.maxWidth > 550
          ? 2
          : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisExtent: 296,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
        ),
        itemBuilder: (_, i) => ProjectCard(
          project: list[i],
          store: s,
          onTap: () => openProject(list[i]),
        ),
      );
    },
  );
  Widget projectsPage() {
    final list = s.projects
        .where(
          (p) => '${p.name} ${p.description} ${p.category}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    return pageScroll([
      heading(
        'Your next big thing starts here.',
        'A home for every idea, from first sketch to final ship.',
        action: FilledButton.icon(
          onPressed: () => projectForm(context, s),
          icon: const Icon(Icons.add, size: 17),
          label: const Text('New project'),
        ),
      ),
      TextField(
        onChanged: (v) => updateView(() => query = v.toLowerCase()),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Find a project...',
        ),
      ),
      const SizedBox(height: 24),
      if (list.isEmpty)
        EmptyView(
          'No projects found',
          'Try a different search, or start something new.',
          onAdd: () => projectForm(context, s),
        )
      else
        projectGrid(list),
    ]);
  }

  Widget taskPage() {
    final list = s.tasks
        .where(
          (t) =>
              (boardProject == 'All projects' || t.projectId == boardProject) &&
              (priority == 'All priorities' || t.priority == priority) &&
              t.title.toLowerCase().contains(query),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Column(
            children: [
              heading(
                'From to-do to ta-da.',
                'Make the next step clear. Keep the momentum going.',
                action: FilledButton.icon(
                  onPressed: s.projects.isEmpty
                      ? null
                      : () => taskForm(context, s),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('New task'),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 210,
                    child: DropdownButtonFormField<String>(
                      initialValue: boardProject,
                      decoration: const InputDecoration(isDense: true),
                      items: [
                        const DropdownMenuItem(
                          value: 'All projects',
                          child: Text(
                            'All projects',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        ...s.projects.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => updateView(() => boardProject = v!),
                    ),
                  ),
                  SizedBox(
                    width: 175,
                    child: DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(isDense: true),
                      items: ['All priorities', ...priorities]
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => updateView(() => priority = v!),
                    ),
                  ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.view_kanban_outlined, size: 17),
                        label: Text('Board'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.list, size: 17),
                        label: Text('List'),
                      ),
                    ],
                    selected: {board},
                    onSelectionChanged: (v) =>
                        updateView(() => board = v.first),
                  ),
                ],
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
        Expanded(
          child: s.projects.isEmpty
              ? EmptyView(
                  'Start with a project',
                  'Tasks need a place to call home.',
                  onAdd: () => projectForm(context, s),
                )
              : !board
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (list.isEmpty)
                      const EmptyView(
                        'No matching tasks',
                        'Try another filter.',
                      ),
                    ...list.map(
                      (t) => TaskTile(
                        task: t,
                        store: s,
                        onTap: () => taskForm(context, s, existing: t),
                      ),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, c) {
                    final width = c.maxWidth > 900
                        ? (c.maxWidth - 72) / 3
                        : 300.0;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: statuses
                            .map(
                              (status) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: width,
                                  child: DragTarget<WorkTask>(
                                    onAcceptWithDetails: (d) =>
                                        s.moveTask(d.data, status),
                                    builder: (context, candidates, rejected) => Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: candidates.isNotEmpty
                                            ? violet.withValues(alpha: .12)
                                            : pastel(
                                                context,
                                                status == 'Done'
                                                    ? const Color(0xffdfece2)
                                                    : status == 'In progress'
                                                    ? const Color(0xffe9e0f2)
                                                    : const Color(0xffefe5da),
                                              ),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 9,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  size: 8,
                                                  color: status == 'Done'
                                                      ? const Color(0xff55a99a)
                                                      : status == 'In progress'
                                                      ? violet
                                                      : muted,
                                                ),
                                                const SizedBox(width: 9),
                                                Text(
                                                  status,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 9),
                                                Tag(
                                                  '${list.where((t) => t.status == status).length}',
                                                  color: muted,
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  tooltip: 'Add $status task',
                                                  onPressed: () => taskForm(
                                                    context,
                                                    s,
                                                    status: status,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView(
                                              children: [
                                                ...list
                                                    .where(
                                                      (t) => t.status == status,
                                                    )
                                                    .map(
                                                      (
                                                        t,
                                                      ) => Draggable<WorkTask>(
                                                        data: t,
                                                        feedback: Material(
                                                          elevation: 6,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child: SizedBox(
                                                            width: 270,
                                                            child: taskCard(t),
                                                          ),
                                                        ),
                                                        childWhenDragging:
                                                            Opacity(
                                                              opacity: .3,
                                                              child: taskCard(
                                                                t,
                                                              ),
                                                            ),
                                                        child: taskCard(t),
                                                      ),
                                                    ),
                                                if (!list.any(
                                                  (t) => t.status == status,
                                                ))
                                                  const Padding(
                                                    padding: EdgeInsets.all(24),
                                                    child: Text(
                                                      'Drop a task here\nor add a new one.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: muted,
                                                        fontSize: 12,
                                                        height: 1.7,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget taskCard(WorkTask t) {
    final p = s.projects.where((p) => p.id == t.projectId).firstOrNull;
    final m = s.members.where((m) => m.id == t.assignee).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: surface(context),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => taskForm(context, s, existing: t),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Tag(
                      p?.category ?? 'Project',
                      color: Color(p?.color ?? violet.toARGB32()),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Move task',
                      icon: const Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: muted,
                      ),
                      onSelected: (v) => s.moveTask(t, v),
                      itemBuilder: (_) => statuses
                          .map(
                            (v) => PopupMenuItem(
                              value: v,
                              child: Text('Move to $v'),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  t.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p?.name ?? '',
                  style: const TextStyle(fontSize: 10, color: muted),
                ),
                if (t.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      t.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Tag(
                      t.priority,
                      color: t.priority == 'High'
                          ? const Color(0xffce786b)
                          : t.priority == 'Low'
                          ? const Color(0xff55a99a)
                          : const Color(0xffc79646),
                    ),
                    const Spacer(),
                    const Icon(Icons.schedule, size: 12, color: muted),
                    const SizedBox(width: 5),
                    Text(
                      dateLabel(t.due),
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                    const SizedBox(width: 9),
                    Avatar(name: m?.name ?? 'Unassigned', size: 26),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget teamPage() => pageScroll([
    heading(
      'Good people. Great possibilities.',
      'Your local team directory. Assign people to tasks and keep work organized.',
      action: FilledButton.icon(
        onPressed: () => memberForm(context, s),
        icon: const Icon(Icons.person_add_alt, size: 17),
        label: const Text('Add member'),
      ),
    ),
    const Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Text(
        'Members are records in this workspace. Adding someone does not send an invitation or grant online access.',
        style: TextStyle(color: muted, fontSize: 12, height: 1.6),
      ),
    ),
    LayoutBuilder(
      builder: (context, c) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: s.members.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: c.maxWidth > 950
              ? 3
              : c.maxWidth > 550
              ? 2
              : 1,
          mainAxisExtent: 220,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
        ),
        itemBuilder: (_, i) {
          final m = s.members[i];
          return Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    Avatar(name: m.name, size: 49, index: i),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remove member',
                      onPressed: () async {
                        if (await confirm(
                          context,
                          'Remove ${m.name}?',
                          'Their tasks will become unassigned.',
                        )) {
                          s.removeMember(m.id);
                        }
                      },
                      icon: const Icon(Icons.more_horiz, color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    m.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    m.role,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.task_alt, size: 14, color: violet),
                    const SizedBox(width: 7),
                    Text(
                      '${s.tasks.where((t) => t.assignee == m.id && t.status != 'Done').length} active tasks',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
    if (s.members.isEmpty)
      const EmptyView(
        'Meet your future team',
        'Add a member to assign work to them.',
      ),
  ]);
  Widget settingsPage() => pageScroll([
    heading(
      'Make yourself at home.',
      'A few details to make this workspace yours.',
    ),
    ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        children: [
          ProfileSettings(store: s),
          const SizedBox(height: 22),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Appearance'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Dark mode',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'A calmer workspace after hours.',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  value: s.dark,
                  onChanged: (v) {
                    s.dark = v;
                    s.changed('Updated appearance');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Your data, your workspace'),
                const Text(
                  'Projects, tasks, members, and preferences are saved in this browser. Export a JSON backup to keep a portable copy. This version has no account system or cloud collaboration.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.8),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => backupDialog(context, s),
                      icon: const Icon(Icons.file_download_outlined, size: 17),
                      label: const Text('Export backup'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => importDialog(context, s),
                      icon: const Icon(Icons.file_upload_outlined, size: 17),
                      label: const Text('Restore backup'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ]);
}

class ProjectDetail extends StatelessWidget {
  final WorkspaceStore store;
  final String projectId;
  const ProjectDetail({
    super.key,
    required this.store,
    required this.projectId,
  });
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final p = store.projects.where((p) => p.id == projectId).firstOrNull;
      if (p == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const EmptyView(
            'Project removed',
            'Go back to your workspace.',
          ),
        );
      }
      final tasks = store.forProject(p.id);
      return Scaffold(
        appBar: AppBar(
          title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: 'Edit project',
              onPressed: () => projectForm(context, store, existing: p),
              icon: const Icon(Icons.edit_outlined),
            ),
            TextButton.icon(
              onPressed: () async {
                final deleted = await deleteProjectWithUndo(context, store, p);
                if (deleted && context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tag(p.category, color: Color(p.color)),
                  const SizedBox(height: 20),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.description,
                    style: const TextStyle(color: muted, height: 1.6),
                  ),
                  const SizedBox(height: 22),
                  Panel(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: violet,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Target: ${dateLabel(p.deadline)}, ${p.deadline.year}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Tag(
                          '${(store.progress(p.id) * 100).round()}% complete',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(
                    'Project tasks',
                    action: 'Add task',
                    onTap: () => taskForm(context, store, projectId: p.id),
                  ),
                  Panel(
                    child: Column(
                      children: [
                        if (tasks.isEmpty)
                          const EmptyView(
                            'Ready when you are',
                            'Add the first task to get started.',
                          ),
                        ...tasks.map(
                          (t) => TaskTile(
                            task: t,
                            store: store,
                            onTap: () => taskForm(context, store, existing: t),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  RepoInsights(
                    key: ValueKey('${p.id}:${p.repository}'),
                    repository: p.repository,
                    onConnect: () => projectForm(context, store, existing: p),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class RepoInsights extends StatefulWidget {
  final String repository;
  final VoidCallback onConnect;
  const RepoInsights({
    super.key,
    required this.repository,
    required this.onConnect,
  });
  @override
  State<RepoInsights> createState() => _RepoInsightsState();
}

class _RepoInsightsState extends State<RepoInsights> {
  Map<String, dynamic>? data;
  String? error;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    if (widget.repository.isNotEmpty) fetch();
  }

  Future<void> fetch() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final r = await http
          .get(
            Uri.https('api.github.com', '/repos/${widget.repository}'),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) {
        throw Exception(
          r.statusCode == 404
              ? 'Repository not found. Check the owner/name and ensure it is public.'
              : r.statusCode == 403 || r.statusCode == 429
              ? 'GitHub rate limit reached. Try again later.'
              : 'GitHub could not be reached (${r.statusCode}).',
        );
      }
      final parsed = jsonDecode(r.body) as Map<String, dynamic>;
      if (mounted) setState(() => data = parsed);
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Repository insights',
          action: widget.repository.isEmpty
              ? 'Connect repository'
              : 'Change repository',
          onTap: widget.onConnect,
        ),
        if (widget.repository.isEmpty)
          const Text(
            'Connect a public GitHub repository in project settings.',
            style: TextStyle(color: muted),
          )
        else ...[
          Text(
            widget.repository,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          if (loading)
            const LinearProgressIndicator()
          else if (error != null) ...[
            Text(error!, style: const TextStyle(color: muted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: fetch, child: const Text('Retry')),
          ] else if (data != null) ...[
            Text(
              data!['description'] ?? 'No repository description.',
              style: const TextStyle(color: muted, height: 1.6),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                Tag('★ ${data!['stargazers_count']} stars'),
                Tag('${data!['forks_count']} forks'),
                Tag('${data!['open_issues_count']} open issues / PRs'),
                Tag(data!['language'] ?? 'Multi-language'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Public GitHub API · Fetched ${dateLabel(DateTime.now())}',
              style: const TextStyle(color: muted, fontSize: 10),
            ),
          ],
        ],
      ],
    ),
  );
}
