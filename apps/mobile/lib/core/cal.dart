import "../core/config.dart";
import "../core/site.dart";

/// Cal.com path without origin, e.g. `nathan-zhao` or `nathan-zhao/30min`.
String getCalPath() {
  final raw = AppConfig.calLink.trim();
  if (raw.isEmpty) {
    return Uri.parse(Site.cal).path.replaceAll(RegExp(r"^/+|/+$"), "");
  }
  return raw
      .replaceFirst(
        RegExp(r"^https?://(www\.)?cal\.com/", caseSensitive: false),
        "",
      )
      .replaceAll(RegExp(r"^/+|/+$"), "");
}

String getCalUrl() {
  final path = getCalPath();
  return path.isEmpty ? Site.cal : "https://cal.com/$path";
}

/// Inline booker URL (keeps UX inside the WebView).
String getCalEmbedUrl() {
  final uri = Uri.parse(getCalUrl());
  return uri
      .replace(
        queryParameters: {
          ...uri.queryParameters,
          "embed": "true",
          "theme": "dark",
          "layout": "month_view",
        },
      )
      .toString();
}
