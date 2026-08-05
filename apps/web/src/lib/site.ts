export const locales = ["en", "zh"] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = "en";

const localePattern = new RegExp(`^/(${locales.join("|")})(?=/|$)`);

export function isLocale(value: string): value is Locale {
  return (locales as readonly string[]).includes(value);
}

/** Strip `/en` or `/zh` prefix; returns `/` for locale root. */
export function stripLocale(pathname: string): string {
  const stripped = pathname.replace(localePattern, "");
  return stripped === "" ? "/" : stripped;
}

export function withLocale(lang: Locale, path = "/"): string {
  const normalized = path.startsWith("/") ? path : `/${path}`;
  if (normalized === "/") return `/${lang}`;
  return `/${lang}${normalized}`;
}

/** Public site meta — no personal name, employers, school, or private email */
export const site = {
  name: "Sunday",
  handle: "sunday",
  jobTitle: "Fullstack Engineer",
  /** Canonical production origin (no trailing slash) */
  url: "https://sundaydev.vercel.app",
  social: {
    github: "https://github.com/sundaydev-arch",
    website: "https://sundaydev.vercel.app/",
  },
  /** Topics for schema.org / GEO — capability-focused, no employers */
  knowsAbout: [
    "TypeScript",
    "Next.js",
    "React",
    "NestJS",
    "FastAPI",
    "Go",
    "multi-tenant portals",
    "BFF",
    "Open API",
  ],
} as const;

export type Project = {
  id: string;
  title: string;
  role: string;
  summary: string;
  highlights: string[];
  tags: string[];
  year: string;
  featured?: boolean;
};
