part of 'app.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
String plannerDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
DateTime plannerDay(DateTime d) => DateUtils.dateOnly(d.toLocal());

enum PlannerView { month, day }

class PlannerPage extends StatefulWidget {
  final WorkspaceStore store;
  final String query;
  final DateTime? initialDate;
  const PlannerPage({
    super.key,
    required this.store,
    this.query = '',
    this.initialDate,
  });
  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late DateTime selected, month;
  PlannerView view = PlannerView.month;
  final quickTitle = TextEditingController();
  final quickForm = GlobalKey<FormState>();
  final dayPanelKey = GlobalKey();
  String? quickProject;
  WorkspaceStore get s => widget.store;
  @override
  void initState() {
    super.initState();
    selected = plannerDay(widget.initialDate ?? DateTime.now());
    month = DateTime(selected.year, selected.month);
  }

  @override
  void dispose() {
    quickTitle.dispose();
    super.dispose();
  }

  String? get projectId => s.projects.any((p) => p.id == quickProject)
      ? quickProject
      : s.projects.firstOrNull?.id;
  List<WorkTask> forDay(DateTime date) {
    final query = widget.query.trim().toLowerCase();
    return s.tasks.where((task) {
      final project = s.projects
          .where((p) => p.id == task.projectId)
          .firstOrNull;
      return DateUtils.isSameDay(plannerDay(task.due), date) &&
          '${task.title} ${task.description} ${project?.name ?? ''}'
              .toLowerCase()
              .contains(query);
    }).toList()..sort((a, b) {
      final done = (a.status == 'Done' ? 1 : 0).compareTo(
        b.status == 'Done' ? 1 : 0,
      );
      return done != 0
          ? done
          : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
  }

  void select(DateTime date, {bool revealDay = false}) {
    setState(() {
      selected = plannerDay(date);
      month = DateTime(selected.year, selected.month);
    });
    final width = MediaQuery.sizeOf(context).width;
    final available =
        width - (width >= 1050 ? 238 : 0) - (width < 700 ? 36 : 60);
    if (revealDay && view == PlannerView.month && available <= 920) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = dayPanelKey.currentContext;
        if (mounted && target != null) {
          Scrollable.ensureVisible(
            target,
            alignment: 0,
            duration: const Duration(milliseconds: 250),
          );
        }
      });
    }
  }

  void step(int direction) {
    if (view == PlannerView.day) {
      select(DateTime(selected.year, selected.month, selected.day + direction));
      return;
    }
    final next = DateTime(month.year, month.month + direction);
    final last = DateUtils.getDaysInMonth(next.year, next.month);
    select(
      DateTime(
        next.year,
        next.month,
        selected.day > last ? last : selected.day,
      ),
    );
  }

  Future<void> addTask({bool quick = false}) async {
    if (quick && !quickForm.currentState!.validate()) return;
    final target = selected;
    if (s.projects.isEmpty) {
      await projectForm(context, s);
      if (!mounted || s.projects.isEmpty) return;
    }
    if (!mounted) return;
    if (quick) {
      s.upsertTask(
        WorkTask(
          id: s.newId(),
          projectId: projectId!,
          title: quickTitle.text.trim(),
          assignee: '',
          due: target,
        ),
      );
      quickTitle.clear();
      FocusScope.of(context).unfocus();
    } else {
      await taskForm(context, s, projectId: projectId, initialDue: target);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: s,
    builder: (context, _) => SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 700 ? 18 : 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final intro = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'YOUR TIME, THOUGHTFULLY PLANNED',
                        style: TextStyle(
                          color: muted,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'A little plan. A clearer day.',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pick a date, make a list, and tick things off.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.6,
                        ),
                      ),
                    ],
                  );
                  return c.maxWidth > 900
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: intro),
                            const SizedBox(width: 18),
                            SizedBox(width: 450, child: controls()),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            intro,
                            const SizedBox(height: 20),
                            controls(),
                          ],
                        );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      view == PlannerView.month
                          ? '${_months[month.month - 1]} ${month.year}'
                          : plannerDate(selected),
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.6,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: view == PlannerView.month
                        ? 'Previous month'
                        : 'Previous day',
                    onPressed: () => step(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    tooltip: view == PlannerView.month
                        ? 'Next month'
                        : 'Next day',
                    onPressed: () => step(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (view == PlannerView.day)
                dayPanel()
              else
                LayoutBuilder(
                  builder: (context, c) => c.maxWidth > 920
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: calendar()),
                            const SizedBox(width: 20),
                            Expanded(flex: 5, child: dayPanel()),
                          ],
                        )
                      : Column(
                          children: [
                            calendar(),
                            const SizedBox(height: 20),
                            dayPanel(),
                          ],
                        ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Dates reflect task due dates. Change a date in task details to move it in the planner.',
                style: TextStyle(fontSize: 10, color: muted, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget controls() => Wrap(
    spacing: 12,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SegmentedButton<PlannerView>(
        segments: const [
          ButtonSegment(
            value: PlannerView.month,
            icon: Icon(Icons.calendar_month_outlined, size: 17),
            label: Text('Month'),
          ),
          ButtonSegment(
            value: PlannerView.day,
            icon: Icon(Icons.view_day_outlined, size: 17),
            label: Text('Day'),
          ),
        ],
        selected: {view},
        onSelectionChanged: (v) => setState(() => view = v.first),
      ),
      OutlinedButton(
        onPressed: () => select(DateTime.now()),
        child: const Text('Today'),
      ),
      FilledButton.icon(
        onPressed: () => addTask(),
        icon: const Icon(Icons.add, size: 17),
        label: const Text('New task'),
      ),
    ],
  );

  Widget calendar() => Panel(
    padding: const EdgeInsets.all(15),
    child: LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 470;
        final start = DateTime(
          month.year,
          month.month,
          1 - (month.weekday - 1),
        );
        final weeks =
            ((month.weekday -
                        1 +
                        DateUtils.getDaysInMonth(month.year, month.month)) /
                    7)
                .ceil();
        final cellHeight = narrow
            ? 65.0
            : ((MediaQuery.sizeOf(context).height - 350) / weeks).clamp(
                60.0,
                94.0,
              );
        final compact = narrow || cellHeight < 80;
        return Column(
          children: [
            Row(
              children: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                  .map(
                    (day) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8,
                            color: muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weeks * 7,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: cellHeight,
                crossAxisSpacing: compact ? 3 : 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, i) {
                final date = DateTime(start.year, start.month, start.day + i);
                final tasks = forDay(date);
                final done = tasks.where((t) => t.status == 'Done').length;
                final active = DateUtils.isSameDay(date, selected),
                    today = DateUtils.isSameDay(date, DateTime.now()),
                    inMonth = date.month == month.month;
                final accent = readableAccent(context, violet);
                return Semantics(
                  selected: active,
                  onTap: () => select(date, revealDay: true),
                  button: true,
                  label: '${plannerDate(date)}, ${tasks.length} tasks',
                  excludeSemantics: true,
                  child: Tooltip(
                    message: '${plannerDate(date)} · ${tasks.length} tasks',
                    child: Material(
                      color: active
                          ? pastel(context, const Color(0xffe4d7ef))
                          : !inMonth
                          ? Theme.of(context).scaffoldBackgroundColor
                          : surface(context),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        key: ValueKey(
                          'planner-date-${date.year}-${date.month}-${date.day}',
                        ),
                        onTap: () => select(date, revealDay: true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(compact ? 5 : 9),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: active
                                  ? accent
                                  : Theme.of(context).dividerColor,
                              width: active ? 1.3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 25,
                                height: 25,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: today ? accent : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: compact ? 11 : 12,
                                    fontWeight: active || today
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: today
                                        ? surface(context)
                                        : ink(context).withValues(
                                            alpha: inMonth ? 1 : .35,
                                          ),
                                  ),
                                ),
                              ),
                              if (tasks.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                if (compact)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 4,
                                        color: done == tasks.length
                                            ? const Color(0xff69a18e)
                                            : accent,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          '${tasks.length}',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  Text(
                                    tasks.first.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: tasks.first.status == 'Done'
                                          ? muted
                                          : accent,
                                      decoration: tasks.first.status == 'Done'
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tasks.length == 1
                                        ? (done == 1 ? 'Completed' : '1 task')
                                        : '${tasks.length} tasks · $done done',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 7,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    ),
  );
  Widget dayPanel() {
    final tasks = forDay(selected),
        done = tasks.where((t) => t.status == 'Done').length;
    return Panel(
      key: dayPanelKey,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: pastel(context, const Color(0xffe3eadf)),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  '${selected.day}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday',
                      ][selected.weekday - 1],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plannerDate(selected),
                      style: const TextStyle(fontSize: 10, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          Row(
            children: [
              const Text(
                'Your day’s checklist',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Tag(
                '$done / ${tasks.length}',
                color: readableAccent(context, violet),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tasks.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: done / tasks.length,
                minHeight: 4,
                color: readableAccent(context, violet),
                backgroundColor: violet.withValues(alpha: .09),
              ),
            ),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: readableAccent(context, violet),
                    size: 25,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.query.isEmpty
                        ? 'A little breathing room.'
                        : 'No matching tasks.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.query.isEmpty
                        ? 'Add your first task for this day below.'
                        : 'Try another search or date.',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ...tasks.map((task) {
            final project = s.projects
                .where((p) => p.id == task.projectId)
                .firstOrNull;
            final checked = task.status == 'Done';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    key: ValueKey('planner-check-${task.id}'),
                    tooltip: checked
                        ? 'Mark ${task.title} incomplete'
                        : 'Mark ${task.title} complete',
                    onPressed: () =>
                        s.moveTask(task, checked ? 'To do' : 'Done'),
                    icon: Icon(
                      checked
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      color: checked
                          ? const Color(0xff69a18e)
                          : readableAccent(context, violet),
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: InkWell(
                      onTap: () => taskForm(context, s, existing: task),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: checked ? muted : ink(context),
                              decoration: checked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            project?.name ?? '',
                            style: const TextStyle(fontSize: 9, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit ${task.title}',
                    onPressed: () => taskForm(context, s, existing: task),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: muted,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          Form(
            key: quickForm,
            child: Column(
              children: [
                if (s.projects.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey(projectId),
                    initialValue: projectId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Project for new tasks',
                      isDense: true,
                    ),
                    items: s.projects
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => quickProject = v),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  key: const ValueKey('planner-quick-task'),
                  controller: quickTitle,
                  maxLength: 100,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => addTask(quick: true),
                  decoration: InputDecoration(
                    labelText: 'Add a task for this day',
                    counterText: '',
                    suffixIcon: IconButton(
                      tooltip: 'Add task to selected day',
                      onPressed: () => addTask(quick: true),
                      icon: const Icon(Icons.add_circle_outline, size: 21),
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter a task title'
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Text(
            s.projects.isEmpty
                ? 'Your first task will start with a new project.'
                : 'New tasks will be due on ${dateLabel(selected)}.',
            style: const TextStyle(color: muted, fontSize: 9, height: 1.6),
          ),
        ],
      ),
    );
  }
}
