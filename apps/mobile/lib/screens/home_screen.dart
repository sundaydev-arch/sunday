import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/site.dart";
import "../core/theme.dart";
import "../i18n/dictionary.dart";
import "../i18n/locale_controller.dart";
import "../widgets/geek_shell.dart";
import "../widgets/project_tile.dart";
import "../widgets/site_footer.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);

    return dictAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("$e")),
      data: (dict) => _HomeBody(dict: dict),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.dict});
  final Dictionary dict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GeekShell(
          minHeight: height - 80,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SundayColors.muted,
                    ),
                    children: [
                      TextSpan(
                        text: "guest@${Site.handle}",
                        style: const TextStyle(color: SundayColors.accent),
                      ),
                      const TextSpan(text: ":"),
                      const TextSpan(
                        text: "~",
                        style: TextStyle(color: SundayColors.ink),
                      ),
                      TextSpan(text: "\$ ${dict.home["whoami"]}"),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
                const SizedBox(height: 16),
                Text(
                      Site.name,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: SundayColors.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 450.ms)
                    .slideY(begin: 0.12),
                const SizedBox(height: 16),
                Text(
                  "// ${dict.home["title"]}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: SundayColors.accent,
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 140.ms, duration: 450.ms),
                const SizedBox(height: 12),
                Text(
                  dict.home["blurb"] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: SundayColors.muted,
                    height: 1.55,
                  ),
                ).animate().fadeIn(delay: 180.ms, duration: 450.ms),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: () => context.go("/projects"),
                      style: FilledButton.styleFrom(
                        backgroundColor: SundayColors.accent,
                        foregroundColor: SundayColors.accentInk,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(dict.home["ctaProjects"] as String),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go("/contact"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SundayColors.ink,
                        side: const BorderSide(color: SundayColors.line),
                        backgroundColor: SundayColors.accentDim,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(dict.home["ctaContact"] as String),
                    ),
                  ],
                ).animate().fadeIn(delay: 240.ms, duration: 450.ms),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (dict.home["selectedLabel"] as String).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: SundayColors.accent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                dict.home["selectedTitle"] as String,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: SundayColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              ...dict.featuredProjects.map(
                (p) => ProjectTile(project: p, compact: true),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go("/projects"),
                child: Text(
                  dict.home["selectedCta"] as String,
                  style: const TextStyle(color: SundayColors.accent),
                ),
              ),
            ],
          ),
        ),
        SiteFooter(dict: dict),
      ],
    );
  }
}
