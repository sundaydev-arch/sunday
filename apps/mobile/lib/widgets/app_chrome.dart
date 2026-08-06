import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme.dart";
import "../i18n/locale_controller.dart";
import "atmosphere.dart";

double appTopChromeInset(BuildContext context) =>
    MediaQuery.paddingOf(context).top + 48;

double appBottomChromeInset(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 80;

/// Locale only — brand lives in page heroes, not duplicated in chrome.
class AppTopBar extends ConsumerWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SundaySpace.pageX),
            child: Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(localeProvider.notifier).toggle(),
                  style: TextButton.styleFrom(
                    foregroundColor: SundayColors.ink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(48, 40),
                  ),
                  child: Text(
                    locale == "en" ? "中文" : "EN",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
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

class AppTabBar extends ConsumerWidget {
  const AppTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const tabs = [
    _TabSpec(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      labelKey: "home",
    ),
    _TabSpec(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      labelKey: "about",
    ),
    _TabSpec(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      labelKey: "projects",
    ),
    _TabSpec(
      icon: Icons.mail_outline_rounded,
      activeIcon: Icons.mail_rounded,
      labelKey: "contact",
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    const barHeight = 68.0;

    return dictAsync.when(
      loading: () => SizedBox(height: barHeight + (bottom > 0 ? bottom : 12)),
      error: (_, _) => const SizedBox.shrink(),
      data: (dict) {
        final selected = selectedIndex.clamp(0, tabs.length - 1);
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 12),
          child: Material(
            elevation: 8,
            shadowColor: const Color(0x1A0F172A),
            borderRadius: BorderRadius.circular(SundayRadii.lg),
            color: SundayColors.navTrack,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SundayRadii.lg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SundayRadii.lg),
                    border: Border.all(color: SundayColors.line),
                  ),
                  child: SizedBox(
                    height: barHeight,
                    child: Row(
                      children: [
                        for (var i = 0; i < tabs.length; i++)
                          Expanded(
                            child: _TabItem(
                              spec: tabs[i],
                              label: dict.navLabel(tabs[i].labelKey),
                              selected: i == selected,
                              onTap: () => onSelect(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.spec,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SundayColors.ink : SundayColors.muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SundayRadii.md),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: selected ? SundayColors.accentDim : Colors.transparent,
                  borderRadius: BorderRadius.circular(SundayRadii.pill),
                ),
                child: Icon(
                  selected ? spec.activeIcon : spec.icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNavRail extends ConsumerWidget {
  const AppNavRail({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);

    return dictAsync.when(
      loading: () => const SizedBox(width: 84),
      error: (_, _) => const SizedBox.shrink(),
      data: (dict) {
        return NavigationRail(
          backgroundColor: SundayColors.backgroundLift,
          selectedIndex: selectedIndex.clamp(0, AppTabBar.tabs.length - 1),
          onDestinationSelected: onSelect,
          labelType: NavigationRailLabelType.all,
          indicatorColor: SundayColors.accentDim,
          selectedIconTheme: const IconThemeData(color: SundayColors.ink),
          unselectedIconTheme: const IconThemeData(color: SundayColors.muted),
          selectedLabelTextStyle: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: SundayColors.ink),
          unselectedLabelTextStyle: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: SundayColors.muted),
          destinations: [
            for (final tab in AppTabBar.tabs)
              NavigationRailDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon),
                label: Text(dict.navLabel(tab.labelKey)),
              ),
          ],
        );
      },
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });

  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
}

class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.child, this.atmosphere = true});

  final Widget child;
  final bool atmosphere;

  @override
  Widget build(BuildContext context) {
    if (!atmosphere) {
      return ColoredBox(color: SundayColors.background, child: child);
    }
    return AtmosphereBackdrop(child: child);
  }
}
