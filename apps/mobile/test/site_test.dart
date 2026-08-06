import "package:flutter_test/flutter_test.dart";
import "package:sunday_mobile/core/site.dart";

void main() {
  test("site identity matches web public brand", () {
    expect(Site.name, "Nathan Zhao");
    expect(Site.handle, "nathan");
    expect(Site.url, "https://sundaydev.vercel.app");
    expect(Site.github, contains("sundaydev-arch"));
    expect(isLocale("en"), isTrue);
    expect(isLocale("zh"), isTrue);
    expect(isLocale("fr"), isFalse);
    expect(defaultLocale, "en");
  });
}
