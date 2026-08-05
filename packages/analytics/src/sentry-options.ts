import type { BrowserOptions, NodeOptions } from "@sentry/nextjs";

type Runtime = "client" | "server" | "edge";

export function getSentrySharedOptions(): Pick<
  NodeOptions,
  "dsn" | "enabled" | "environment" | "tracesSampleRate"
> {
  const dsn = process.env.NEXT_PUBLIC_SENTRY_DSN;
  return {
    dsn,
    enabled: Boolean(dsn),
    environment: process.env.NODE_ENV,
    tracesSampleRate: process.env.NODE_ENV === "development" ? 1.0 : 0.1,
  };
}

/** Client-only options (replay). Import only from browser instrumentation. */
export function getSentryClientOptions(): BrowserOptions {
  return {
    ...getSentrySharedOptions(),
    replaysSessionSampleRate: 0,
    replaysOnErrorSampleRate: 1.0,
  };
}

export type { Runtime };
