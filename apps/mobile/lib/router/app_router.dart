import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/analytics.dart";
import "../screens/about_screen.dart";
import "../screens/contact_screen.dart";
import "../screens/home_screen.dart";
import "../screens/projects_screen.dart";
import "../widgets/pill_nav.dart";

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: "/",
    observers: [_AnalyticsNavigatorObserver()],
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: "/",
            name: "home",
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: "/about",
            name: "about",
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: "/projects",
            name: "projects",
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: "/contact",
            name: "contact",
            builder: (context, state) => const ContactScreen(),
          ),
        ],
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          const Positioned(top: 0, left: 0, right: 0, child: PillNav()),
        ],
      ),
    );
  }
}

class _AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _track(newRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name ?? route.settings.arguments?.toString();
    final path = name ?? "/";
    Analytics.instance.capturePageView(path);
  }
}
