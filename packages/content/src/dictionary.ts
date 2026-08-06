import en from "./messages/en.json";
import zh from "./messages/zh.json";
import { isLocale, type Locale, type Project } from "./site";

const dictionaries = { en, zh } as const;

export type Dictionary = typeof en;

export function getDictionary(lang: Locale): Dictionary {
  return dictionaries[lang];
}

export function getProjectsFromDict(dict: Dictionary): Project[] {
  return dict.items.map((item) => ({
    id: item.id,
    title: item.title,
    role: item.role,
    summary: item.summary,
    highlights: item.highlights,
    tags: item.tags,
    year: item.year,
    featured: item.featured,
  }));
}

export function resolveLocale(value: string | null | undefined): Locale {
  if (value && isLocale(value)) return value;
  return "en";
}
