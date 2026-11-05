part of 'app.dart';

bool isNight(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
Color pastel(BuildContext context, Color color) =>
    isNight(context) ? Color.lerp(const Color(0xff302938), color, .13)! : color;
Color readableAccent(BuildContext context, Color color) => isNight(context)
    ? Color.lerp(color, Colors.white, .42)!
    : Color.lerp(color, const Color(0xff302336), .22)!;

class StudioSidebar extends StatelessWidget {
  final WorkspaceStore store;
  final String page;
  final Map<String, IconData> navs;
  final ValueChanged<String> onNavigate;
  final VoidCallback onCreate;
  const StudioSidebar({
    super.key,
    required this.store,
    required this.page,
    required this.navs,
    required this.onNavigate,
    required this.onCreate,
  });
  @override
  Widget build(BuildContext context) {
    final night = isNight(context);
    return Container(
      width: 238,
      decoration: BoxDecoration(
        color: pastel(context, const Color(0xffeee8f2)),
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const BrandMark(),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'stack space',
                                style: TextStyle(
                                  color: ink(context),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 45, top: 4),
                        child: Text(
                          'THE STUDENT DEVELOPER WORKSPACE',
                          style: TextStyle(
                            color: muted,
                            fontSize: 6.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surface(context).withValues(alpha: .65),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 33,
                              height: 33,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: pastel(context, const Color(0xffe1d2eb)),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                Icons.workspace_premium_outlined,
                                color: readableAccent(context, violet),
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.workspace,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Personal workspace',
                                    style: TextStyle(fontSize: 9, color: muted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.unfold_more_rounded,
                              color: muted,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.only(left: 13, bottom: 15),
                        child: Text(
                          'YOUR WORKSPACE',
                          style: TextStyle(
                            fontSize: 8,
                            color: muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                      ...navs.entries.map((e) {
                        final selected = e.key == page;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Material(
                            color: selected
                                ? (night
                                      ? const Color(0xffd6bde9)
                                      : const Color(0xff6a5279))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                            child: InkWell(
                              onTap: () => onNavigate(e.key),
                              borderRadius: BorderRadius.circular(13),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      e.value,
                                      size: 19,
                                      color: selected
                                          ? (night
                                                ? const Color(0xff302238)
                                                : Colors.white)
                                          : muted,
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Text(
                                        e.key,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: selected
                                              ? (night
                                                    ? const Color(0xff302238)
                                                    : Colors.white)
                                              : ink(context)
                                                    .withValues(alpha: .75),
                                        ),
                                      ),
                                    ),
                                    if (e.key == 'Task board' ||
                                        (e.key == 'Bin' &&
                                            store.bin.isNotEmpty))
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Colors.white.withValues(
                                                  alpha: .17,
                                                )
                                              : violet.withValues(alpha: .10),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          '${e.key == 'Bin' ? store.bin.length : store.tasks.where((t) => t.status != 'Done').length}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: selected
                                                ? (night
                                                      ? const Color(0xff302238)
                                                      : Colors.white)
                                                : muted,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: pastel(context, const Color(0xffe2e9d9)),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.terminal_rounded,
                                  color: readableAccent(
                                    context,
                                    const Color(0xff72836b),
                                  ),
                                  size: 20,
                                ),
                                const Spacer(),
                                Text(
                                  'BUILD / ITERATE / SHIP',
                                  style: TextStyle(
                                    color: ink(context).withValues(alpha: .55),
                                    fontSize: 6.5,
                                    letterSpacing: .7,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Plan. Build.\nShip. Repeat.',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 23,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Break it down. Build it out.\nKeep your team in sync.',
                              style: TextStyle(
                                fontSize: 10,
                                color: muted,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 15),
                            InkWell(
                              onTap: onCreate,
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Start a project',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.north_east,
                                    size: 16,
                                    color: ink(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 23),
                      Row(
                        children: [
                          Avatar(name: store.name, size: 36),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Workspace owner',
                                  style: TextStyle(fontSize: 9, color: muted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Workspace settings',
                            onPressed: () => onNavigate('Settings'),
                            icon: const Icon(
                              Icons.tune_rounded,
                              size: 17,
                              color: muted,
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
      ),
    );
  }
}

class StudioGreeting extends StatelessWidget {
  final String name;
  const StudioGreeting({super.key, required this.name});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WORKSPACE / MISSION CONTROL',
                style: TextStyle(
                  color: muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome back, ${name.split(' ').first}.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: c.maxWidth < 600 ? 30 : 37,
                  letterSpacing: -1.2,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Your projects, priorities, and team. One clear view.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.6),
              ),
            ],
          ),
        ),
        if (c.maxWidth > 850)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(30),
              color: surface(context),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 15, color: muted),
                const SizedBox(width: 8),
                Text(
                  '${dateLabel(DateTime.now())}, ${DateTime.now().year}',
                  style: const TextStyle(fontSize: 10, color: muted),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class StudioHero extends StatelessWidget {
  final VoidCallback onCreate;
  final int completed, total;
  const StudioHero({
    super.key,
    required this.onCreate,
    required this.completed,
    required this.total,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final compact = c.maxWidth < 650;
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: pastel(context, const Color(0xffe0e9df)),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -80,
              bottom: -130,
              child: Container(
                width: 390,
                height: 390,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ink(context).withValues(alpha: .035),
                    width: 55,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 26 : 32),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Build smarter.\nShip together.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: compact ? 37 : 47,
                            fontWeight: FontWeight.w700,
                            height: 1.02,
                            letterSpacing: -1.6,
                            color: ink(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            'One workspace for your code, your team,\nand the next thing you’re building.',
                            style: TextStyle(
                              color: ink(context).withValues(alpha: .6),
                              fontSize: 12,
                              height: 1.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 15,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: onCreate,
                              icon: const Icon(Icons.add, size: 17),
                              label: const Text(
                                'Create a project',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '$completed tasks completed',
                              style: TextStyle(
                                fontSize: 10,
                                color: ink(context).withValues(alpha: .6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!compact)
                    Expanded(
                      flex: 5,
                      child: DeveloperScene(completed: completed, total: total),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
