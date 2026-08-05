import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

test.describe("a11y + visuals", () => {
  test("home has no serious axe violations", async ({ page }) => {
    await page.goto("/en");
    const results = await new AxeBuilder({ page })
      .disableRules(["color-contrast"])
      .analyze();
    const serious = results.violations.filter((v) =>
      ["serious", "critical"].includes(v.impact ?? ""),
    );
    expect(serious).toEqual([]);
  });

  test("contact screenshot smoke", async ({ page }) => {
    await page.goto("/en/contact");
    await expect(page.getByRole("heading", { name: /ping me/i })).toBeVisible();
    await page.screenshot({
      path: "test-results/contact-en.png",
      fullPage: true,
    });
  });
});
