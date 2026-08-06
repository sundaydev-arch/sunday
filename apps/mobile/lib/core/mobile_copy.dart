/// App-facing copy overrides.
/// Shared JSON keeps the web terminal voice; mobile shows plain, readable labels.
abstract final class MobileCopy {
  static bool _zh(String locale) => locale.startsWith("zh");

  static String viewAll(String locale) => _zh(locale) ? "查看全部" : "View all";

  static String aboutTitle(String locale) => _zh(locale) ? "关于" : "About";

  static String contactTitle(String locale) => _zh(locale) ? "联系我" : "Contact";

  static String focus(String locale) => _zh(locale) ? "方向" : "Focus";

  static String strengths(String locale) => _zh(locale) ? "优势" : "Strengths";

  static String stack(String locale) => _zh(locale) ? "技术栈" : "Stack";

  static String name(String locale) => _zh(locale) ? "姓名" : "Name";

  static String email(String locale) => _zh(locale) ? "邮箱" : "Email";

  static String message(String locale) => _zh(locale) ? "留言" : "Message";

  static String nameHint(String locale) => _zh(locale) ? "你的名字" : "Your name";

  static String emailHint(String locale) =>
      _zh(locale) ? "you@company.com" : "you@company.com";

  static String messageHint(String locale) =>
      _zh(locale) ? "岗位、技术栈、时间线…" : "Role, stack, timeline…";

  static String submit(String locale) => _zh(locale) ? "发送" : "Send message";

  static String sending(String locale) => _zh(locale) ? "发送中…" : "Sending…";

  static String formLead(String locale) =>
      _zh(locale) ? "发一条消息" : "Send a message";
}
