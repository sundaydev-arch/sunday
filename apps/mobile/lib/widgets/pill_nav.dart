import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/site.dart";
import "../core/theme.dart";
import "../i18n/locale_controller.dart";

class PillNav extends ConsumerWidget {
  const PillNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);
    final location = GoRouterState.of(context).uri.path;

    return dictAsync.when(
      loading: () => const SizedBox(height: 56),
      error: (_, _) => const SizedBox.shrink(),
      data: (dict) {
        final items = [
          _NavItem(label: dict.navLabel("home"), path: "/"),
          _NavItem(label: dict.navLabel("about"), path: "/about"),
          _NavItem(label: dict.navLabel("projects"), path: "/projects"),
          _NavItem(label: dict.navLabel("contact"), path: "/contact"),
        ];

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: SundayColors.navTrack.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SundayColors.line),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "~/${Site.handle}",
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: SundayColors.accent),
                        ),
                      ),
                      ...items.map((item) {
                        final active = _isActive(location, item.path);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: TextButton(
                            onPressed: () => context.go(item.path),
                            style: TextButton.styleFrom(
                              foregroundColor: active
                                  ? SundayColors.accentInk
                                  : SundayColors.foreground,
                              backgroundColor: active
                                  ? SundayColors.accent
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(item.label),
                          ),
                        );
                      }),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () =>
                            ref.read(localeProvider.notifier).toggle(),
                        style: TextButton.styleFrom(
                          foregroundColor: SundayColors.muted,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(locale == "en" ? "中文" : "EN"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isActive(String location, String path) {
    if (path == "/") return location == "/";
    return location == path || location.startsWith("$path/");
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.path});
  final String label;
  final String path;
}
