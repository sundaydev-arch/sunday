import { notFound } from "next/navigation";
import { isLocale, type Locale } from "@/lib/site";
import type { Project } from "@/lib/site";

const dictionaries = {
  en: () => import("./dictionaries/en.json").then((m) => m.default),
  zh: () => import("./dictionaries/zh.json").then((m) => m.default),
};

export type Dictionary = Awaited<ReturnType<(typeof dictionaries)["en"]>>;

export async function getDictionary(lang: string): Promise<Dictionary> {
  if (!isLocale(lang)) notFound();
  return dictionaries[lang as Locale]();
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
