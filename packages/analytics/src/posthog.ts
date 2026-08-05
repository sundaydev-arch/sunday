"use client";

import type { PostHog } from "posthog-js";
import { AnalyticsEvents, type AnalyticsEvent } from "./events";

export function captureEvent(
  posthog: PostHog | null | undefined,
  event: AnalyticsEvent | (string & {}),
  properties?: Record<string, unknown>,
) {
  posthog?.capture(event, properties);
}

export function capturePageView(
  posthog: PostHog | null | undefined,
  url: string,
) {
  captureEvent(posthog, AnalyticsEvents.PageView, { $current_url: url });
}

export { AnalyticsEvents };
