import { expect, test } from "@playwright/test";

test.describe("home", () => {
  test("loads English home and switches language", async ({ page }) => {
    await page.goto("/en");
    await expect(page.getByText("Nathan Zhao").first()).toBeVisible();

    const nav = page.getByRole("navigation", { name: "Primary" });
    await expect(
      nav.getByRole("link", { name: "Projects", exact: true }),
    ).toBeVisible();

    await page.getByRole("link", { name: "zh", exact: true }).click();
    await expect(page).toHaveURL(/\/zh/);
    await expect(
      nav.getByRole("link", { name: "项目", exact: true }),
    ).toBeVisible();
  });

  test("projects page renders anonymized cases", async ({ page }) => {
    await page.goto("/en/projects");
    await expect(
      page.getByRole("heading", { name: /Selected projects/i }),
    ).toBeVisible();
    await expect(page.getByText(/Multi-tenant Portal/i).first()).toBeVisible();
  });
});
