/// Public site meta — mirrors `apps/web/src/lib/site.ts`.
/// No employers, school, or private email on the public surface.
const locales = ["en", "zh"];
typedef LocaleCode = String;

const defaultLocale = "en";

bool isLocale(String value) => locales.contains(value);

class Site {
  const Site._();

  static const name = "Nathan Zhao";
  static const handle = "nathan";
  static const jobTitle = "Fullstack Engineer";

  /// Canonical production origin (no trailing slash).
  static const url = "https://sundaydev.vercel.app";

  static const github = "https://github.com/sundaydev-arch";
  static const website = "https://sundaydev.vercel.app/";
  static const cal = "https://cal.com/nathan-zhao";

  static const knowsAbout = [
    "TypeScript",
    "Next.js",
    "React",
    "NestJS",
    "FastAPI",
    "Go",
    "multi-tenant portals",
    "BFF",
    "Open API",
  ];
}

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.role,
    required this.summary,
    required this.highlights,
    required this.tags,
    required this.year,
    this.featured = false,
  });

  final String id;
  final String title;
  final String role;
  final String summary;
  final List<String> highlights;
  final List<String> tags;
  final String year;
  final bool featured;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json["id"] as String,
      title: json["title"] as String,
      role: json["role"] as String,
      summary: json["summary"] as String,
      highlights: (json["highlights"] as List<dynamic>).cast<String>(),
      tags: (json["tags"] as List<dynamic>).cast<String>(),
      year: json["year"] as String,
      featured: json["featured"] as bool? ?? false,
    );
  }
}
