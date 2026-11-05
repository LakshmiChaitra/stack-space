part of 'app.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: pastel(context, const Color(0xffd8c4e7)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      Icons.code_rounded,
      color: readableAccent(context, violet),
      size: 23,
    ),
  );
}

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final int index;
  const Avatar({super.key, required this.name, this.size = 30, this.index = 0});
  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xffe5ddff),
      Color(0xffffe8d7),
      Color(0xffdaf0e8),
      Color(0xffdee8fd),
    ];
    return Tooltip(
      message: name,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: BoxShape.circle,
          border: Border.all(color: surface(context), width: 2),
        ),
        child: Text(
          initials(name),
          style: TextStyle(
            color: const Color(0xff554679),
            fontSize: size * .3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(23),
    this.color,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: color ?? surface(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(23),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  const Tag(this.text, {super.key, this.color = violet});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: readableAccent(context, color).withValues(alpha: .11),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: readableAccent(context, color),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -.4,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action!,
                  style: const TextStyle(fontSize: 11, color: muted),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 14, color: muted),
              ],
            ),
          ),
      ],
    ),
  );
}

class EmptyView extends StatelessWidget {
  final String title, description;
  final VoidCallback? onAdd;
  const EmptyView(this.title, this.description, {super.key, this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.layers_outlined, size: 44, color: violet),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, height: 1.6),
          ),
          if (onAdd != null)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create new'),
              ),
            ),
        ],
      ),
    ),
  );
}

class ProjectCard extends StatefulWidget {
  final Project project;
  final WorkspaceStore store;
  final VoidCallback onTap;
  const ProjectCard({
    super.key,
    required this.project,
    required this.store,
    required this.onTap,
  });
  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final s = widget.store;
    final color = readableAccent(context, Color(p.color));
    final tasks = s.forProject(p.id);
    final done = tasks.where((t) => t.status == 'Done').length;
    final members = s.members
        .where((m) => tasks.any((t) => t.assignee == m.id))
        .take(3)
        .toList();
    final base = p.category == 'Design'
        ? const Color(0xfff2e1d5)
        : p.category == 'Mobile app'
        ? const Color(0xffdde9e3)
        : const Color(0xffe9dff0);
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, hovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: Color(p.color).withValues(alpha: hovered ? .12 : .025),
              blurRadius: hovered ? 24 : 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: surface(context),
          borderRadius: BorderRadius.circular(23),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 73,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: pastel(context, base)),
                  child: Row(
                    children: [
                      Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          color: surface(context).withValues(alpha: .6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          p.category == 'Design'
                              ? Icons.interests_outlined
                              : p.category == 'Mobile app'
                              ? Icons.hub_outlined
                              : Icons.terminal_rounded,
                          size: 20,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            color: color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                      Icon(Icons.north_east_rounded, size: 18, color: color),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          p.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              '$done of ${tasks.length} tasks',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(s.progress(p.id) * 100).round()}%',
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: s.progress(p.id)),
                          duration: const Duration(milliseconds: 700),
                          builder: (_, v, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: v,
                              color: color,
                              backgroundColor: color.withValues(alpha: .10),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),
                        Row(
                          children: [
                            if (members.isEmpty)
                              const Text(
                                'Your next idea awaits',
                                style: TextStyle(color: muted, fontSize: 9),
                              )
                            else
                              SizedBox(
                                width: 70,
                                height: 27,
                                child: Stack(
                                  children: [
                                    for (int i = 0; i < members.length; i++)
                                      Positioned(
                                        left: i * 20.0,
                                        child: Avatar(
                                          name: members[i].name,
                                          size: 27,
                                          index: i,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: pastel(
                                  context,
                                  base,
                                ).withValues(alpha: .7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 10,
                                    color: color,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    dateLabel(p.deadline),
                                    style: TextStyle(fontSize: 9, color: color),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value, caption;
  final IconData icon;
  final Color color;
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final base = icon == Icons.folder_outlined
        ? const Color(0xffe9dff0)
        : icon == Icons.timelapse_rounded
        ? const Color(0xfff3e9c9)
        : icon == Icons.task_alt_rounded
        ? const Color(0xffdfece3)
        : const Color(0xfff3dfdc);
    final accent = readableAccent(context, color);
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: pastel(context, base),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: surface(context).withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  style: TextStyle(
                    color: ink(context).withValues(alpha: .6),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: accent, size: 18),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 43,
                  height: 1,
                  letterSpacing: -1.8,
                  color: ink(context),
                ),
              ),
              const Spacer(),
              Container(
                width: 31,
                height: 25,
                decoration: BoxDecoration(
                  color: surface(context).withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.north_east, size: 13, color: accent),
              ),
            ],
          ),
          const Spacer(),
          Text(
            caption,
            maxLines: 2,
            style: TextStyle(
              color: ink(context).withValues(alpha: .55),
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final WorkTask task;
  final WorkspaceStore store;
  final VoidCallback onTap;
  const TaskTile({
    super.key,
    required this.task,
    required this.store,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final project = store.projects
        .where((p) => p.id == task.projectId)
        .firstOrNull;
    final member = store.members
        .where((m) => m.id == task.assignee)
        .firstOrNull;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Checkbox(
              value: task.status == 'Done',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onChanged: (v) =>
                  store.moveTask(task, v == true ? 'Done' : 'To do'),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: task.status == 'Done'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project?.name ?? 'Project',
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (MediaQuery.sizeOf(context).width > 600)
              Tag(
                task.priority,
                color: task.priority == 'High'
                    ? const Color(0xffd57c6b)
                    : task.priority == 'Low'
                    ? const Color(0xff55a99a)
                    : const Color(0xffc79646),
              ),
            const SizedBox(width: 16),
            Text(
              dateLabel(task.due),
              style: const TextStyle(color: muted, fontSize: 10),
            ),
            const SizedBox(width: 12),
            Avatar(name: member?.name ?? 'Unassigned', size: 28),
          ],
        ),
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  final double value;
  final int completed, total;
  const ProgressRing({
    super.key,
    required this.value,
    required this.completed,
    required this.total,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    width: 160,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 145,
          height: 145,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 850),
            builder: (_, v, _) => CircularProgressIndicator(
              value: v,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              color: violet,
              backgroundColor: violet.withValues(alpha: .09),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'completed',
              style: TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );
}
