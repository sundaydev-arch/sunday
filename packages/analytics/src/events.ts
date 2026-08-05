/** Typed event names — keep product analytics consistent across apps */
export const AnalyticsEvents = {
  PageView: "$pageview",
  ContactSubmitSucceeded: "contact_submit_succeeded",
  ContactSubmitFailed: "contact_submit_failed",
} as const;

export type AnalyticsEvent =
  (typeof AnalyticsEvents)[keyof typeof AnalyticsEvents];
