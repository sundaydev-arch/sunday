import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme.dart";
import "../i18n/locale_controller.dart";
import "../widgets/app_chrome.dart";
import "../widgets/app_error.dart";
import "../widgets/page_header.dart";
import "../widgets/project_tile.dart";
import "../widgets/site_footer.dart";

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);

    return dictAsync.when(
      loading: () =>
          const PageScaffold(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => PageScaffold(
        child: AppErrorView(
          title: "Couldn't load projects",
          detail: "$e",
          onRetry: () => ref.invalidate(dictionaryProvider),
        ),
      ),
      data: (dict) {
        final projects = dict.projects;
        final items = dict.items;
        return PageScaffold(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              SundaySpace.pageX,
              appTopChromeInset(context) + 8,
              SundaySpace.pageX,
              appBottomChromeInset(context),
            ),
            children: [
              PageHeader(
                title: projects["title"] as String,
                blurb: projects["blurb"] as String,
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Container(height: 1, color: SundayColors.line),
                ProjectTile(project: items[i], index: i + 1),
              ],
              SiteFooter(dict: dict),
            ],
          ),
        );
      },
    );
  }
}
