import { AnalyticsEvents } from "@sunday/analytics/events";
import * as Sentry from "@sentry/react";
import posthog, { type PostHog } from "posthog-js";
import { config } from "@/lib/config";

let posthogClient: PostHog | null = null;
let sentryReady = false;

export function initAnalytics() {
  if (config.sentryDsn && !sentryReady) {
    Sentry.init({
      dsn: config.sentryDsn,
      environment: config.sentryEnvironment,
      release: `sunday-desktop@${__APP_VERSION__}`,
      tracesSampleRate: 0.1,
    });
    sentryReady = true;
  }

  if (config.posthogKey && !posthogClient) {
    posthog.init(config.posthogKey, {
      api_host: config.posthogHost,
      capture_pageview: false,
      persistence: "localStorage",
    });
    posthogClient = posthog;
  }
}

export function getPostHog(): PostHog | null {
  return posthogClient;
}

export function captureEvent(
  event: string,
  properties?: Record<string, unknown>,
) {
  posthogClient?.capture(event, properties);
}

export function capturePageView(url: string) {
  captureEvent(AnalyticsEvents.PageView, { $current_url: url });
}

export function captureException(
  error: unknown,
  context?: Record<string, unknown>,
) {
  if (!sentryReady) return;
  if (context) {
    Sentry.withScope((scope) => {
      scope.setExtras(context);
      Sentry.captureException(error);
    });
    return;
  }
  Sentry.captureException(error);
}

export { AnalyticsEvents };
