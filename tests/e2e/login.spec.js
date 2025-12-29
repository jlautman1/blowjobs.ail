// Basic login flow tests for BlowJobs.ai
// These will be executed by Playwright MCP using playwright.config.js

const { test, expect } = require('@playwright/test');

// Demo credentials seeded in the backend (see README)
const VALID_EMAIL = 'jobseeker@demo.com';
const VALID_PASSWORD = 'demo123';

test.describe('Login experience', () => {
  test('shows error and stays on login with wrong password', async ({ page }) => {
    await page.goto('/');

    // Go to Login from welcome screen
    await page.getByRole('button', { name: /sign in/i }).click();

    // Fill wrong password
    await page.getByLabel(/email/i).fill(VALID_EMAIL);
    await page.getByLabel(/password/i).fill('wrong-password');
    await page.getByRole('button', { name: /sign in/i }).click();

    // Expect an error message and still be on /login
    await expect(page.getByText(/invalid email or password/i)).toBeVisible();
    await expect(page).toHaveURL(/\/login/);
  });

  test('navigates to home on successful login', async ({ page }) => {
    await page.goto('/');

    // Go to Login
    await page.getByRole('button', { name: /sign in/i }).click();

    // Fill correct credentials
    await page.getByLabel(/email/i).fill(VALID_EMAIL);
    await page.getByLabel(/password/i).fill(VALID_PASSWORD);
    await page.getByRole('button', { name: /^sign in$/i }).click();

    // Expect redirect to /home and greeting text
    await expect(page).toHaveURL(/\/home/);
    await expect(page.getByText(/hi, /i)).toBeVisible();
  });
});


