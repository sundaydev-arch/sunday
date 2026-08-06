import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/mobile_copy.dart";
import "../core/site.dart";
import "../core/theme.dart";
import "../i18n/dictionary.dart";
import "../i18n/locale_controller.dart";
import "../widgets/app_chrome.dart";
import "../widgets/app_error.dart";
import "../widgets/project_tile.dart";
import "../widgets/site_footer.dart";
import "../widgets/splash_gate.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);
    final splashDone = ref.watch(splashDoneProvider);

    return dictAsync.when(
      loading: () =>
          const PageScaffold(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => PageScaffold(
        child: AppErrorView(
          title: "Couldn't load home",
          detail: "$e",
          onRetry: () => ref.invalidate(dictionaryProvider),
        ),
      ),
      data: (dict) => PageScaffold(
        child: _HomeBody(dict: dict, locale: locale, reveal: splashDone),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.dict,
    required this.locale,
    required this.reveal,
  });
  final Dictionary dict;
  final String locale;
  final bool reveal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPad = appBottomChromeInset(context);
    final featured = dict.featuredProjects.take(2).toList();
    final play = reveal ? 1.0 : 0.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        SundaySpace.pageX,
        appTopChromeInset(context) + 8,
        SundaySpace.pageX,
        bottomPad,
      ),
      children: [
        // —— Hero ——
        Text(
              Site.name,
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 46),
            )
            .animate(target: play)
            .fadeIn(duration: 450.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic, duration: 450.ms),
        const SizedBox(height: 16),
        Text(
          dict.home["title"] as String,
          style: theme.textTheme.titleMedium?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w600,
            height: 1.4,
            fontSize: 18,
          ),
        ).animate(target: play).fadeIn(delay: 60.ms, duration: 400.ms),
        const SizedBox(height: 14),
        Text(
          dict.home["blurb"] as String,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: SundayColors.muted,
            height: 1.55,
          ),
        ).animate(target: play).fadeIn(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => context.go("/projects"),
                child: Text(dict.navLabel("projects")),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go("/contact"),
                child: Text(dict.navLabel("contact")),
              ),
            ),
          ],
        ).animate(target: play).fadeIn(delay: 140.ms, duration: 400.ms),

        const SizedBox(height: 56),

        // —— Selected work ——
        Text(
          locale.startsWith("zh") ? "作品" : "WORK",
          style: theme.textTheme.labelSmall?.copyWith(
            color: SundayColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dict.home["selectedTitle"] as String,
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: SundayColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < featured.length; i++) ...[
          if (i > 0) Container(height: 1, color: SundayColors.line),
          ProjectTile(project: featured[i], compact: true, index: i + 1)
              .animate(target: play)
              .fadeIn(delay: (180 + i * 60).ms, duration: 400.ms)
              .slideY(begin: 0.04, duration: 400.ms, curve: Curves.easeOut),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.go("/projects"),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(0, 48),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(MobileCopy.viewAll(locale)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
        SiteFooter(dict: dict),
      ],
    );
  }
}
