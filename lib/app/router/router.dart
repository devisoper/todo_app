import 'package:go_router/go_router.dart';

import '../../ui/layouts/editor_layout/editor_layout.dart';
import '../../ui/layouts/home_layout/home_layout.dart';
import '../models/note.dart';
import 'routes.dart';

/// App's router
final router = GoRouter(
  initialLocation: '/$routeHomeLayout',
  routes: [
    GoRoute(
      name: routeHomeLayout,
      path: '/$routeHomeLayout',
      builder: (_, __) => const HomeLayout(),
      routes: [
        GoRoute(
          name: routeEditorLayout,
          path: routeEditorLayout,
          builder: (_, state) => EditorLayout(
            noteID: state.extra as Note?,
          ),
        ),
      ],
    ),
  ],
);
