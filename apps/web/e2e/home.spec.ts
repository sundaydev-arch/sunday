import { expect, test } from "@playwright/test";

test.describe("home", () => {
  test("loads English home and switches language", async ({ page }) => {
    await page.goto("/en");
    await expect(page.getByText("Sunday").first()).toBeVisible();
    await expect(page.getByRole("link", { name: "Projects" })).toBeVisible();

    await page.getByRole("link", { name: "zh" }).click();
    await expect(page).toHaveURL(/\/zh/);
    await expect(page.getByRole("link", { name: "项目" })).toBeVisible();
  });

  test("projects page renders anonymized cases", async ({ page }) => {
    await page.goto("/en/projects");
    await expect(
      page.getByRole("heading", { name: /Selected projects/i }),
    ).toBeVisible();
    await expect(page.getByText(/Multi-tenant Portal/i).first()).toBeVisible();
  });
});
