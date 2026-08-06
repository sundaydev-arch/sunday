import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/analytics.dart";
import "../core/site.dart";
import "../core/theme.dart";
import "../screens/about_screen.dart";
import "../screens/contact_screen.dart";
import "../screens/home_screen.dart";
import "../screens/in_app_browser_screen.dart";
import "../screens/projects_screen.dart";
import "../widgets/app_chrome.dart";
import "../widgets/app_error.dart";
import "../widgets/offline_banner.dart";

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: "/",
    observers: [_AnalyticsNavigatorObserver()],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: SundayColors.background,
      body: AppErrorView(
        title: "Route not found",
        detail: state.uri.toString(),
        onRetry: () => context.go("/"),
      ),
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/",
                name: "home",
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/about",
                name: "about",
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/projects",
                name: "projects",
                builder: (context, state) => const ProjectsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/contact",
                name: "contact",
                builder: (context, state) => const ContactScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/browse",
        name: "browse",
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final url = state.uri.queryParameters["url"] ?? Site.website;
          final title = state.uri.queryParameters["title"];
          return InAppBrowserScreen(url: url, title: title);
        },
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _railBreakpoint = 840.0;

  void _select(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: SundayColors.background,
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: wide
                  ? Row(
                      children: [
                        AppNavRail(
                          selectedIndex: navigationShell.currentIndex,
                          onSelect: _select,
                        ),
                        Expanded(child: navigationShell),
                      ],
                    )
                  : ColoredBox(
                      color: SundayColors.background,
                      child: navigationShell,
                    ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [AppTopBar(), OfflineBanner()],
              ),
            ),
          ],
        ),
        bottomNavigationBar: wide
            ? null
            : AppTabBar(
                selectedIndex: navigationShell.currentIndex,
                onSelect: _select,
              ),
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
