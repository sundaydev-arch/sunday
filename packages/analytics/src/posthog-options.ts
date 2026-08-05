import type { PostHogConfig } from "posthog-js";

export type PostHogInitEnv = {
  key?: string;
  apiHost?: string;
  uiHost?: string;
};

export function getPostHogInitOptions(
  env: PostHogInitEnv = {},
): { key: string; options: Partial<PostHogConfig> } | null {
  const key = env.key ?? process.env.NEXT_PUBLIC_POSTHOG_KEY;
  if (!key) return null;

  return {
    key,
    options: {
      api_host:
        env.apiHost ?? process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "/ingest",
      ui_host:
        env.uiHost ??
        process.env.NEXT_PUBLIC_POSTHOG_UI_HOST ??
        "https://us.posthog.com",
      capture_pageview: false,
      capture_pageleave: true,
      person_profiles: "identified_only",
      persistence: "localStorage+cookie",
    },
  };
}
