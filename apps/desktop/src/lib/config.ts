import { site } from "@/lib/site";

function env(key: keyof ImportMetaEnv): string {
  const value = import.meta.env[key];
  return typeof value === "string" ? value.trim() : "";
}

export const config = {
  apiBaseUrl: env("VITE_API_BASE_URL") || site.url,
  turnstileSiteKey: env("VITE_TURNSTILE_SITE_KEY"),
  sentryDsn: env("VITE_SENTRY_DSN"),
  posthogKey: env("VITE_POSTHOG_KEY"),
  posthogHost: env("VITE_POSTHOG_HOST") || "https://us.i.posthog.com",
  calLinkRaw: env("VITE_CAL_LINK") || site.social.cal,
  sentryEnvironment: env("VITE_SENTRY_ENVIRONMENT") || "development",
} as const;
