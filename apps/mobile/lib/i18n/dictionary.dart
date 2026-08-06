import "dart:convert";

import "package:flutter/services.dart";

import "../core/site.dart";

class Strength {
  const Strength({required this.label, required this.value});
  final String label;
  final String value;

  factory Strength.fromJson(Map<String, dynamic> json) =>
      Strength(label: json["label"] as String, value: json["value"] as String);
}

class Dictionary {
  Dictionary(this._raw);

  final Map<String, dynamic> _raw;

  Map<String, dynamic> get nav => _raw["nav"] as Map<String, dynamic>;
  Map<String, dynamic> get home => _raw["home"] as Map<String, dynamic>;
  Map<String, dynamic> get about => _raw["about"] as Map<String, dynamic>;
  Map<String, dynamic> get projects => _raw["projects"] as Map<String, dynamic>;
  Map<String, dynamic> get contact => _raw["contact"] as Map<String, dynamic>;
  Map<String, dynamic> get footer => _raw["footer"] as Map<String, dynamic>;
  Map<String, dynamic> get meta => _raw["meta"] as Map<String, dynamic>;

  String navLabel(String key) => nav[key] as String? ?? key;

  List<Project> get items {
    final list = _raw["items"] as List<dynamic>? ?? const [];
    return list
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<Project> get featuredProjects =>
      items.where((p) => p.featured).take(3).toList();

  List<Strength> get strengths {
    final list = about["strengths"] as List<dynamic>? ?? const [];
    return list
        .map((e) => Strength.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, String> get skills {
    final raw = about["skills"] as Map<String, dynamic>? ?? {};
    return raw.map((k, v) => MapEntry(k, v as String));
  }

  Map<String, String> get contactFields {
    final raw = contact["fields"] as Map<String, dynamic>? ?? {};
    return raw.map((k, v) => MapEntry(k, v as String));
  }

  Map<String, String> get contactValidation {
    final raw = contact["validation"] as Map<String, dynamic>? ?? {};
    return raw.map((k, v) => MapEntry(k, v as String));
  }

  static Future<Dictionary> load(String locale) async {
    final code = isLocale(locale) ? locale : defaultLocale;
    final json = await rootBundle.loadString("assets/messages/$code.json");
    return Dictionary(jsonDecode(json) as Map<String, dynamic>);
  }
}
