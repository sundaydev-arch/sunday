import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/mobile_copy.dart";
import "../core/site.dart";
import "../core/theme.dart";
import "../i18n/locale_controller.dart";
import "../widgets/app_chrome.dart";
import "../widgets/app_error.dart";
import "../widgets/cal_embed.dart";
import "../widgets/contact_form.dart";
import "../widgets/page_header.dart";
import "../widgets/site_footer.dart";

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);

    return dictAsync.when(
      loading: () =>
          const PageScaffold(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => PageScaffold(
        child: AppErrorView(
          title: "Couldn't load contact",
          detail: "$e",
          onRetry: () => ref.invalidate(dictionaryProvider),
        ),
      ),
      data: (dict) {
        final contact = dict.contact;
        final width = MediaQuery.sizeOf(context).width;

        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: MobileCopy.contactTitle(locale),
              blurb: contact["blurb"] as String,
            ),
            const SizedBox(height: 24),
            SiteLinks(
              links: [
                (contact["github"] as String, Site.github),
                (contact["website"] as String, Site.website),
              ],
            ),
          ],
        );

        return PageScaffold(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              SundaySpace.pageX,
              appTopChromeInset(context) + 12,
              SundaySpace.pageX,
              appBottomChromeInset(context),
            ),
            children: [
              if (width >= 840)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 36),
                    Expanded(child: ContactForm(dict: dict)),
                  ],
                )
              else ...[
                intro,
                const SizedBox(height: 36),
                ContactForm(dict: dict),
              ],
              const SizedBox(height: SundaySpace.section),
              PageHeader(
                title: contact["calTitle"] as String,
                blurb: contact["calBlurb"] as String,
              ),
              const SizedBox(height: 20),
              const CalEmbed(),
              SiteFooter(dict: dict),
            ],
          ),
        );
      },
    );
  }
}
