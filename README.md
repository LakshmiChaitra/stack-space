# Stack Space

[Live app](https://lakshmichaitra.github.io/stack-space/) · Responsive Flutter project workspace

A responsive Flutter web workspace for student developers. Manage projects, move tasks through a Kanban board, assign team members, and view public GitHub repository statistics.

## Run

Install the Flutter stable SDK (this project was built with Dart 3.13.2), then:

```sh
flutter pub get
flutter run -d chrome
```

Alternatively use `flutter run -d web-server --web-port 8080` and open the address shown. No API keys or account setup are needed.

## Build and test

```sh
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```

Deploy the contents of `build/web` to a static web host. To preview a release build locally:

```sh
python3 -m http.server 8080 --directory build/web
```

## Working features

- Overview dashboard: computed project/task/member counts, completion ring, upcoming work, and recent activity.
- Create, read, update, and delete projects with description, category, color, target date, and optional public GitHub repository.
- Project detail route with its tasks and live repository statistics.
- Three-column drag-and-drop Kanban board; accessible task menus and form status selectors provide alternatives to dragging. Horizontal board scrolling on compact screens.
- Task creation/editing/deletion, descriptions, assignment, priorities, due dates, project and priority filters, and list view.
- Local team directory; removing a member unassigns their tasks.
- First-visit name prompt with a Chaitra fallback, remembered in the current browser. Existing custom profile names are preserved.
- Light/dark themes and editable workspace profile.
- Persistent browser storage with serialized writes and visible save errors.
- Copy/export and validated restore of portable JSON workspace backups.
- Public GitHub REST API integration with loading, not-found, timeout, rate-limit, and retry states. The included Flutter repository is sample data, not a repository created for this app.

The initial workspace contains sample projects, members, and tasks. You can edit or remove them. Dates are relative to first launch. Empty project progress is 0%.

## Assignment requirements → implementation

| Requirement | Implementation |
| --- | --- |
| Different widgets | Container, Row, Column, Stack, GridView, ListView, Material cards, buttons, dialogs, progress indicators, DropdownButtonFormField, DragTarget and Draggable. See `lib/ui/`. |
| Responsive design | MediaQuery switches the desktop sidebar to a mobile/tablet drawer at 1050 px. LayoutBuilder adjusts card columns, hero illustration, dashboard panels, and task board width. Scrollable navigation supports short viewports. |
| Navigation | Persistent shell navigation between Overview, Projects, Task board, Team, and Settings. Navigator + MaterialPageRoute opens project details and supports Back navigation. |
| Animations | AnimatedSwitcher with fade/slide screen transitions, TweenAnimationBuilder for progress bars/rings, Material interaction effects and route transitions. |
| State management | StatefulWidget for UI state; WorkspaceStore extends ChangeNotifier. ListenableBuilder subscribes to the shared workspace. This uses Flutter's built-in observable state management rather than adding Provider unnecessarily. |
| Themes/custom widgets | Central ThemeData/ColorScheme, persisted ThemeMode, and reusable Panel, Avatar, Tag, ProjectCard, TaskTile, StatCard, SectionTitle, EmptyView and ProgressRing. |
| Forms/validation | Form + GlobalKey<FormState>, TextFormField validators, required trimmed text, GitHub owner/repository format, date pickers, controlled category/status/priority/member values, and atomic backup validation. |

## Source organization

```text
lib/
  main.dart                     Bootstrap and load saved state
  models/workspace.dart         Project, WorkTask, Member JSON models
  state/workspace_store.dart    State, persistence, CRUD, backups, progress
  ui/app.dart                   Theme, app shell, navigation
  ui/components.dart            Reusable presentation widgets
  ui/pages.dart                 Screens, repository API integration
  ui/forms.dart                 Validated dialogs and profile settings
  ui/welcome.dart               First-visit name prompt and Chaitra fallback
  ui/studio.dart                Adaptive palette, workspace sidebar and hero
  ui/developer_art.dart         Code-window artwork and workspace progress
```

The UI files use Dart `part` declarations to share library-private implementation while keeping screens, forms, and reusable components in separate files.

## Scope and limitations

This is a complete **local single-user assignment version**. Team members are directory records, not authenticated users. There are no invitations, cloud synchronization, login, role-based security, or real-time multi-user collaboration. It requires no Firebase account. Do not claim those features on your résumé until they are implemented and tested.

Browser storage is appropriate for this prototype, not critical records. Clearing site data removes the local workspace. Export backups regularly. GitHub lookups require internet access; unauthenticated API rate limits apply. Counts for GitHub open issues also include pull requests. A connected repository's information is fetched on opening project details; it is not background-synchronized.

For a future collaborative version, introduce Firebase Authentication, a workspace membership model, Firestore persistence, server-enforced security rules, and emulator tests covering cross-workspace access. Keep local UI state separate from backend authorization.

## Demo / viva flow

1. Explain the overview metrics and responsive layout.
2. Create a project; demonstrate empty-form validation first.
3. Open its detail screen and create a task with a member and due date.
4. Move the task from To do to In progress to Done using the task board menu or dragging.
5. Show computed progress updating on the project and dashboard.
6. Edit the project and connect `flutter/flutter`; show public GitHub insights.
7. Add a local team member, assign a task, then remove the member to show safe unassignment.
8. Switch theme, refresh, and verify saved state.
9. Export a backup and demonstrate restore. Explain that restore replaces the workspace.
10. Resize to desktop, tablet, and mobile and discuss the layout decisions.

## Tests

Automated tests cover persistence across reloads, progress calculations, cascading project deletion, member unassignment, atomic rejection of invalid backups, and responsive navigation + task form validation/submission at desktop, short desktop, tablet, and mobile sizes.

Screenshots are in `screenshots/`. The bundled Manrope and Fraunces fonts are distributed under the SIL Open Font License in `assets/fonts/OFL.txt` and `assets/fonts/Fraunces-OFL.txt`. All artwork is built with Flutter widgets.

## Honest résumé description

“Built a responsive Flutter web project workspace with a drag-and-drop Kanban board, persistent local state, validated forms, JSON backup/restore, and GitHub REST API integration; tested desktop, tablet, and mobile layouts.”

Add measured usage or performance figures only after collecting them.

## Stack Space developer theme

The pastel theme uses a cream canvas, lavender sidebar, sage hero, and butter/blush/mint statistics. Dark mode uses deep plum surfaces and pastel accents. The hero contains a developer code window and task-driven progress, with no astronaut, planet, or hero badge. Existing projects and Indian team names are preserved.

The theme toggle is the sun/moon control in the top bar, or the Dark mode switch in Settings. The preference survives reloads. Automated responsive tests cover four viewports in both themes (eight widget tests plus persistence and name-migration tests).

Sample team members are Aarav Sharma, Priya Reddy, Arjun Rao, and Ananya Iyer. Existing unchanged sample names are migrated on load; custom member and profile names are preserved.

The app is branded **Stack Space**. The Dart package identifier, workspace directory, and existing browser-storage key remain `devboard` for compatibility with saved projects and source imports.

## GitHub Pages deployment

The app is deployed at https://lakshmichaitra.github.io/stack-space/. Pushes to `main` run `.github/workflows/deploy.yml`: Flutter analysis, tests, a release build with `--base-href /stack-space/`, and a GitHub Pages deployment. GitHub Pages must use GitHub Actions as its publishing source. The pipeline uses Flutter 3.47.2 to match the project SDK.

Workspace data is stored per browser and origin, so local preview data does not transfer automatically to the deployed URL. Use Settings → Export backup / Restore backup to transfer it.
