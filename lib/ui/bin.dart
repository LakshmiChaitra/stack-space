part of 'app.dart';

class BinPage extends StatefulWidget {
  final WorkspaceStore store;
  final String query;
  const BinPage({super.key, required this.store, this.query = ''});
  @override
  State<BinPage> createState() => _BinPageState();
}

class _BinPageState extends State<BinPage> {
  String filter = 'All';
  WorkspaceStore get s => widget.store;
  Future<void> purge(BinItem item) async {
    final linked = s.bin
        .where((b) => !b.isProject && b.project.id == item.project.id)
        .length;
    if (await confirm(
      context,
      'Delete ${item.title} forever?',
      item.isProject
          ? 'This permanently removes this project, its ${item.tasks.length} linked tasks, and $linked separately binned tasks for this project. This cannot be undone.'
          : 'This permanently removes the task from the Bin. This cannot be undone.',
    )) {
      s.permanentlyDeleteBinItem(item.id);
    }
  }

  Future<void> empty() async {
    if (await confirm(
      context,
      'Empty the Bin?',
      'Permanently remove all ${s.bin.length} items and all tasks inside deleted projects? This cannot be undone.',
    )) {
      s.emptyBin();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: s,
    builder: (context, _) {
      final query = widget.query.trim().toLowerCase();
      final items = s.bin
          .where(
            (item) =>
                (filter == 'All' ||
                    (filter == 'Projects' && item.isProject) ||
                    (filter == 'Tasks' && !item.isProject)) &&
                '${item.title} ${item.project.name} ${item.tasks.map((t) => t.title).join(' ')}'
                    .toLowerCase()
                    .contains(query),
          )
          .toList();
      return SingleChildScrollView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 700 ? 18 : 30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROOM FOR SECOND CHANCES',
                  style: TextStyle(
                    color: muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Not gone. Just in the Bin.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 11),
                const Text(
                  'Restore deleted projects and tasks whenever you need them. Nothing here is emptied automatically.',
                  style: TextStyle(fontSize: 12, color: muted, height: 1.7),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'All', label: Text('All')),
                        ButtonSegment(
                          value: 'Projects',
                          label: Text('Projects'),
                        ),
                        ButtonSegment(value: 'Tasks', label: Text('Tasks')),
                      ],
                      selected: {filter},
                      onSelectionChanged: (v) =>
                          setState(() => filter = v.first),
                    ),
                    OutlinedButton.icon(
                      onPressed: s.bin.isEmpty ? null : empty,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 17),
                      label: const Text('Empty Bin'),
                    ),
                    Tag(
                      '${s.bin.length} ${s.bin.length == 1 ? 'item' : 'items'}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (items.isEmpty)
                  Panel(
                    child: EmptyView(
                      s.bin.isEmpty ? 'All clear.' : 'No matching items.',
                      s.bin.isEmpty
                          ? 'Deleted projects and tasks will appear here.\nYour active workspace is safe.'
                          : 'Try another filter or search.',
                    ),
                  ),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: binCard(item),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'The Bin is saved in this browser and included in JSON backups. Emptying it only removes deleted items.',
                  style: TextStyle(fontSize: 10, color: muted, height: 1.7),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  Widget binCard(BinItem item) {
    final parentMissing = !s.projects.any((p) => p.id == item.project.id);
    final deleted = item.deletedAt.toLocal();
    final activeProject = s.projects
        .where((p) => p.id == item.project.id)
        .firstOrNull;
    return Panel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: pastel(
                    context,
                    item.isProject
                        ? const Color(0xffe8def0)
                        : const Color(0xffdfece5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.isProject
                      ? Icons.folder_outlined
                      : Icons.task_alt_rounded,
                  color: readableAccent(context, violet),
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.isProject
                          ? 'Project · ${item.tasks.length} linked tasks'
                          : 'Task · ${activeProject?.name ?? item.project.name}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Tag(item.isProject ? 'Project' : 'Task'),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            'Moved to Bin ${dateLabel(deleted)}, ${deleted.year} · ${deleted.hour.toString().padLeft(2, '0')}:${deleted.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 10, color: muted),
          ),
          if (item.isProject && item.tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  ...item.tasks
                      .take(3)
                      .map(
                        (task) => ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: Tag(task.title),
                        ),
                      ),
                  if (item.tasks.length > 3)
                    Tag('+${item.tasks.length - 3} more'),
                ],
              ),
            ),
          if (!item.isProject && parentMissing)
            const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text(
                'Restoring this task also restores its project and any tasks grouped with that project in the Bin.',
                style: TextStyle(fontSize: 11, color: muted, height: 1.6),
              ),
            ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: ValueKey('restore-bin-${item.id}'),
                onPressed: () {
                  if (s.restoreBinItem(item.id)) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored ${item.title}')),
                    );
                  }
                },
                icon: const Icon(Icons.restore_rounded, size: 17),
                label: Text(
                  !item.isProject && parentMissing
                      ? 'Restore project & task'
                      : 'Restore',
                ),
              ),
              TextButton.icon(
                key: ValueKey('purge-bin-${item.id}'),
                onPressed: () => purge(item),
                icon: const Icon(Icons.delete_forever_outlined, size: 18),
                label: const Text('Delete forever'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
