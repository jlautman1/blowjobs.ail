// Script to capture screenshots for README using Playwright
// Usage: 
//   1. Start backend: cd backend && go run ./cmd/server
//   2. Start frontend: cd frontend && flutter run -d chrome --web-port=8081
//   3. Run this: node scripts/take_screenshots.js

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const VALID_EMAIL = 'jobseeker@demo.com';
const VALID_PASSWORD = 'demo123';
const BASE_URL = process.env.E2E_BASE_URL || 'http://localhost:8081';
const OUTPUT_DIR = path.join(__dirname, '../docs/images');

// Ensure output directory exists
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

async function takeScreenshots() {
  console.log('Starting screenshot capture...');
  console.log(`Using base URL: ${BASE_URL}`);
  
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
  });
  const page = await context.newPage();

  try {
    // 1. Welcome screen
    console.log('Capturing welcome screen...');
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    await page.screenshot({ 
      path: path.join(OUTPUT_DIR, 'welcome.png'),
      fullPage: true 
    });
    console.log('✓ Welcome screen saved');

    // 2. Login screen
    console.log('Navigating to login...');
    await page.getByRole('button', { name: /sign in/i }).click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    await page.screenshot({ 
      path: path.join(OUTPUT_DIR, 'login.png'),
      fullPage: true 
    });
    console.log('✓ Login screen saved');

    // 3. Login and capture home screen
    console.log('Logging in...');
    await page.getByLabel(/email/i).fill(VALID_EMAIL);
    await page.getByLabel(/password/i).fill(VALID_PASSWORD);
    await page.getByRole('button', { name: /^sign in$/i }).click();
    
    // Wait for home screen
    await page.waitForURL(/\/home/, { timeout: 10000 });
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    await page.screenshot({ 
      path: path.join(OUTPUT_DIR, 'home.png'),
      fullPage: true 
    });
    console.log('✓ Home screen saved');

    // 4. Navigate to swipe and capture
    console.log('Navigating to swipe screen...');
    await page.getByRole('button', { name: /swipe/i }).click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000); // Wait for cards to load
    await page.screenshot({ 
      path: path.join(OUTPUT_DIR, 'swipe.png'),
      fullPage: true 
    });
    console.log('✓ Swipe screen saved');

    console.log('\n✅ All screenshots captured successfully!');
    console.log(`📁 Saved to: ${OUTPUT_DIR}`);

  } catch (error) {
    console.error('❌ Error capturing screenshots:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

takeScreenshots();

