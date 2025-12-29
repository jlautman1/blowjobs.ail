// Playwright configuration for BlowJobs.ai web app
// This is kept minimal so Playwright MCP can pick it up and run.

const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests/e2e',
  timeout: 30 * 1000,
  expect: {
    timeout: 5000,
  },
  use: {
    // Point this to your deployed Netlify URL via env var,
    // e.g. E2E_BASE_URL=https://your-site.netlify.app
    baseURL: process.env.E2E_BASE_URL || 'http://localhost:8081',
    headless: true,
    viewport: { width: 1280, height: 720 },
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});


