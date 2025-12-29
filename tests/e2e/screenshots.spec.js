// Script to capture screenshots for README
// Run with: npx playwright test tests/e2e/screenshots.spec.js --headed

const { test, expect } = require('@playwright/test');
const path = require('path');

const VALID_EMAIL = 'jobseeker@demo.com';
const VALID_PASSWORD = 'demo123';

test.describe('Screenshot capture for README', () => {
  test('capture all screenshots', async ({ page }) => {
    // Navigate to welcome screen
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.screenshot({ 
      path: path.join(__dirname, '../../docs/images/welcome.png'),
      fullPage: true 
    });

    // Navigate to login
    await page.getByRole('button', { name: /sign in/i }).click();
    await page.waitForLoadState('networkidle');
    await page.screenshot({ 
      path: path.join(__dirname, '../../docs/images/login.png'),
      fullPage: true 
    });

    // Login
    await page.getByLabel(/email/i).fill(VALID_EMAIL);
    await page.getByLabel(/password/i).fill(VALID_PASSWORD);
    await page.getByRole('button', { name: /^sign in$/i }).click();
    
    // Wait for home screen
    await page.waitForURL(/\/home/, { timeout: 10000 });
    await page.waitForLoadState('networkidle');
    await page.screenshot({ 
      path: path.join(__dirname, '../../docs/images/home.png'),
      fullPage: true 
    });

    // Navigate to swipe screen
    await page.getByRole('button', { name: /swipe/i }).click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000); // Wait for cards to load
    await page.screenshot({ 
      path: path.join(__dirname, '../../docs/images/swipe.png'),
      fullPage: true 
    });
  });
});

