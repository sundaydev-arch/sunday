import { expect, test } from "@playwright/test";

test.describe("performance smoke", () => {
  test("home document loads under budget", async ({ page }) => {
    const start = Date.now();
    const response = await page.goto("/en", { waitUntil: "domcontentloaded" });
    const elapsed = Date.now() - start;

    expect(response?.ok()).toBeTruthy();
    expect(elapsed).toBeLessThan(8_000);

    const paint = await page.evaluate(() => {
      const nav = performance.getEntriesByType("navigation")[0] as
        | PerformanceNavigationTiming
        | undefined;
      return {
        domContentLoaded: nav?.domContentLoadedEventEnd ?? 0,
        transferSize: nav?.transferSize ?? 0,
      };
    });

    expect(paint.domContentLoaded).toBeGreaterThan(0);
  });
});
