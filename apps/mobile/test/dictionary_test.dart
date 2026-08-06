import "package:flutter_test/flutter_test.dart";
import "package:sunday_mobile/i18n/dictionary.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("loads English dictionary with projects", () async {
    final dict = await Dictionary.load("en");
    expect(dict.navLabel("home"), "Home");
    expect(dict.items, isNotEmpty);
    expect(dict.featuredProjects.length, lessThanOrEqualTo(3));
    expect(dict.home["whoami"], "whoami");
    expect(dict.contactFields["submit"], "submit --force");
  });

  test("loads Chinese dictionary", () async {
    final dict = await Dictionary.load("zh");
    expect(dict.navLabel("home"), "首页");
    expect(dict.about["title"], "运行时笔记");
    expect(dict.items.first.title, contains("Portal"));
  });
}
