import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/workspace.dart';
import '../state/workspace_store.dart';
part 'components.dart';
part 'pages.dart';
part 'forms.dart';
part 'studio.dart';
part 'developer_art.dart';
part 'welcome.dart';
part 'planner.dart';

const violet = Color(0xff806497);
const muted = Color(0xff89818e);
const statuses = ['To do', 'In progress', 'Done'];
const priorities = ['High', 'Medium', 'Low'];
String dateLabel(DateTime d) =>
    '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.day}';
String initials(String s) => s
    .trim()
    .split(RegExp(r'\s+'))
    .take(2)
    .map((x) => x.isEmpty ? '' : x[0])
    .join()
    .toUpperCase();
Color surface(BuildContext c) => Theme.of(c).colorScheme.surface;
Color ink(BuildContext c) => Theme.of(c).colorScheme.onSurface;

class StackSpaceApp extends StatelessWidget {
  final WorkspaceStore store;
  const StackSpaceApp({super.key, required this.store});
  ThemeData theme(bool dark) {
    final scheme = ColorScheme.fromSeed(
      seedColor: violet,
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: dark ? const Color(0xff2d2736) : const Color(0xfffffdf9),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xff211c29)
          : const Color(0xfff8f5f0),
      fontFamily: 'Manrope',
      dividerColor: dark ? Colors.white12 : const Color(0xffeae4ec),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 14, color: scheme.onSurface),
        bodySmall: const TextStyle(color: muted, fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xff382f41) : const Color(0xfff8f5f0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dark
              ? const Color(0xffd6bde9)
              : const Color(0xff665171),
          foregroundColor: dark
              ? const Color(0xff2b2134)
              : const Color(0xfffffdf9),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'Stack Space — Build smarter. Ship together.',
      debugShowCheckedModeBanner: false,
      theme: theme(false),
      darkTheme: theme(true),
      themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
      home: store.hasChosenName
          ? WorkspaceShell(store: store)
          : WelcomeScreen(store: store),
    ),
  );
}

class WorkspaceShell extends StatefulWidget {
  final WorkspaceStore store;
  const WorkspaceShell({super.key, required this.store});
  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  String page = 'Overview',
      query = '',
      boardProject = 'All projects',
      priority = 'All priorities';
  bool board = true;
  WorkspaceStore get s => widget.store;
  final search = TextEditingController();
  final scaffold = GlobalKey<ScaffoldState>();
  static const navs = {
    'Overview': Icons.space_dashboard_outlined,
    'Projects': Icons.folder_outlined,
    'Task board': Icons.view_kanban_outlined,
    'Planner': Icons.calendar_month_outlined,
    'Team': Icons.people_outline,
    'Settings': Icons.tune_rounded,
  };
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void updateView(VoidCallback fn) => setState(fn);
  void navigate(String value) {
    if (boardProject != 'All projects' &&
        !s.projects.any((p) => p.id == boardProject)) {
      boardProject = 'All projects';
    }

    setState(() {
      page = value;
      query = '';
      search.clear();
    });
  }

  void openProject(Project p) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ProjectDetail(store: s, projectId: p.id),
    ),
  );
  Widget sidebar() => StudioSidebar(
    store: s,
    page: page,
    navs: navs,
    onNavigate: (value) {
      navigate(value);
      scaffold.currentState?.closeDrawer();
    },
    onCreate: () => projectForm(context, s),
  );
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1050;
    return Scaffold(
      key: scaffold,
      drawer: wide ? null : Drawer(width: 238, child: sidebar()),
      body: Row(
        children: [
          if (wide) sidebar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 76,
                  padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!wide)
                        IconButton(
                          tooltip: 'Open navigation',
                          onPressed: () => scaffold.currentState?.openDrawer(),
                          icon: const Icon(Icons.menu),
                        ),
                      Text(
                        page,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (MediaQuery.sizeOf(context).width > 680)
                        SizedBox(
                          width: 245,
                          child: TextField(
                            controller: search,
                            onChanged: (v) =>
                                setState(() => query = v.toLowerCase()),
                            decoration: const InputDecoration(
                              hintText: 'Search projects & tasks...',
                              hintStyle: TextStyle(fontSize: 12, color: muted),
                              prefixIcon: Icon(Icons.search, size: 19),
                              isDense: true,
                              contentPadding: EdgeInsets.all(13),
                            ),
                          ),
                        ),
                      const SizedBox(width: 18),
                      IconButton(
                        tooltip: s.dark
                            ? 'Switch to light theme'
                            : 'Switch to dark theme',
                        onPressed: () {
                          s.dark = !s.dark;
                          s.changed('Changed workspace theme');
                        },
                        icon: Icon(
                          s.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 21,
                          color: muted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Avatar(name: s.name, size: 36),
                    ],
                  ),
                ),
                if (s.storageError != null)
                  MaterialBanner(
                    content: Text(s.storageError!),
                    actions: [
                      TextButton(
                        onPressed: () => navigate('Settings'),
                        child: const Text('Export backup'),
                      ),
                    ],
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, .025),
                          end: Offset.zero,
                        ).animate(a),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(page),
                      child: page == 'Overview'
                          ? overview()
                          : page == 'Projects'
                          ? projectsPage()
                          : page == 'Task board'
                          ? taskPage()
                          : page == 'Planner'
                          ? PlannerPage(store: s, query: query)
                          : page == 'Team'
                          ? teamPage()
                          : settingsPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
