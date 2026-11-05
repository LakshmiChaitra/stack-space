import 'package:flutter/material.dart';

import 'state/workspace_store.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = WorkspaceStore();
  await store.load();
  runApp(StackSpaceApp(store: store));
}
