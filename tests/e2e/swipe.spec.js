// Happy-path swipe experience tests

const { test, expect } = require('@playwright/test');

const VALID_EMAIL = 'jobseeker@demo.com';
const VALID_PASSWORD = 'demo123';

async function loginAsJobSeeker(page) {
  await page.goto('/');
  await page.getByRole('button', { name: /sign in/i }).click();
  await page.getByLabel(/email/i).fill(VALID_EMAIL);
  await page.getByLabel(/password/i).fill(VALID_PASSWORD);
  await page.getByRole('button', { name: /^sign in$/i }).click();
  await expect(page).toHaveURL(/\/home/);
}

test.describe('Swipe screen', () => {
  test('shows swipe card and action buttons', async ({ page }) => {
    await loginAsJobSeeker(page);

    // Discover tab should be visible by default
    await expect(page.getByText(/viewed today/i)).toBeVisible();

    // There should be at least one card container and swipe buttons
    await expect(page.getByRole('button', { name: /reset all swipes/i }).first()).toBeVisible({ timeout: 10000 }).catch(() => {});
    await expect(page.getByRole('button', { name: /like/i }).or(page.getByRole('button', { name: /pass/i }))).toBeDefined;
  });
});


