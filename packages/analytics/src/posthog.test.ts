import { describe, expect, it, vi } from "vitest";
import {
  AnalyticsEvents,
  captureEvent,
  capturePageView,
} from "@sunday/analytics";

describe("analytics helpers", () => {
  it("forwards pageview and typed events", () => {
    const capture = vi.fn();
    const posthog = { capture } as never;

    capturePageView(posthog, "https://example.com/en");
    captureEvent(posthog, AnalyticsEvents.ContactSubmitSucceeded);

    expect(capture).toHaveBeenCalledWith("$pageview", {
      $current_url: "https://example.com/en",
    });
    expect(capture).toHaveBeenCalledWith("contact_submit_succeeded", undefined);
  });

  it("no-ops when posthog is missing", () => {
    expect(() => capturePageView(null, "https://example.com")).not.toThrow();
  });
});
