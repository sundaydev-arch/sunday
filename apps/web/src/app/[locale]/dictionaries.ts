import { notFound } from "next/navigation";
import {
  getDictionary as loadDictionary,
  getProjectsFromDict,
  isLocale,
  type Dictionary,
  type Locale,
} from "@sunday/content";

export type { Dictionary };
export { getProjectsFromDict };

export async function getDictionary(lang: string): Promise<Dictionary> {
  if (!isLocale(lang)) notFound();
  return loadDictionary(lang as Locale);
}
