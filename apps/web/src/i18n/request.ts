import { getRequestConfig } from "next-intl/server";
import { hasLocale } from "next-intl";
import { getDictionary, isLocale, type Locale } from "@sunday/content";
import { routing } from "./routing";

export default getRequestConfig(async ({ requestLocale }) => {
  const requested = await requestLocale;
  const locale = hasLocale(routing.locales, requested)
    ? requested
    : routing.defaultLocale;

  const messages = isLocale(locale)
    ? getDictionary(locale as Locale)
    : getDictionary(routing.defaultLocale as Locale);

  return {
    locale,
    messages,
  };
});
