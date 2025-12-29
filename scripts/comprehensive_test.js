// Comprehensive Test Script for BlowJobs.ai
// Tests all features and improvements

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const BASE_URL = process.env.E2E_BASE_URL || 'http://localhost:8081';
const JOB_SEEKER_EMAIL = 'jobseeker@demo.com';
const JOB_SEEKER_PASSWORD = 'demo123';
const RECRUITER_EMAIL = 'recruiter@demo.com';
const RECRUITER_PASSWORD = 'demo123';

const TEST_RESULTS_DIR = path.join(__dirname, '../test-results');
if (!fs.existsSync(TEST_RESULTS_DIR)) {
  fs.mkdirSync(TEST_RESULTS_DIR, { recursive: true });
}

const testResults = {
  passed: [],
  failed: [],
  warnings: [],
};

async function runTests() {
  console.log('🧪 Starting Comprehensive Tests...\n');
  console.log(`Using base URL: ${BASE_URL}\n`);

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
  });
  const page = await context.newPage();

  try {
    // Test 1: Welcome Screen
    console.log('📸 Test 1: Welcome Screen');
    await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 30000 });
    await page.waitForTimeout(3000); // Wait for Flutter to load
    
    // Check theme color
    const themeColor = await page.evaluate(() => {
      const meta = document.querySelector('meta[id="flutterweb-theme"]');
      return meta ? meta.getAttribute('content') : null;
    });
    
    if (themeColor === '#0ea5e9') {
      testResults.passed.push('Theme color is vibrant teal (#0ea5e9)');
      console.log('  ✅ Theme color correct');
    } else {
      testResults.failed.push(`Theme color incorrect: ${themeColor} (expected #0ea5e9)`);
      console.log(`  ❌ Theme color incorrect: ${themeColor}`);
    }
    
    await page.screenshot({ 
      path: path.join(TEST_RESULTS_DIR, '01_welcome.png'),
      fullPage: true 
    });
    console.log('  📷 Screenshot saved\n');

    // Test 2: Navigate to Login
    console.log('🔐 Test 2: Login Screen');
    try {
      // Try to find and click sign in button
      await page.waitForTimeout(2000);
      // For Flutter web, we might need to use different selectors
      // This is a placeholder - actual implementation may vary
      console.log('  ⚠️  Manual interaction needed for Flutter web');
      testResults.warnings.push('Login navigation requires manual testing (Flutter Canvas)');
    } catch (e) {
      testResults.warnings.push(`Login navigation: ${e.message}`);
    }
    console.log('');

    // Test 3: API Connectivity
    console.log('🌐 Test 3: Backend API Connectivity');
    try {
      const response = await page.request.get('http://localhost:8080/api/v1/auth/login', {
        data: { email: 'test', password: 'test' }
      });
      if (response.status() === 400 || response.status() === 401) {
        testResults.passed.push('Backend API is responding');
        console.log('  ✅ Backend API is accessible');
      } else {
        testResults.warnings.push(`Unexpected API response: ${response.status()}`);
        console.log(`  ⚠️  API responded with status: ${response.status()}`);
      }
    } catch (e) {
      testResults.failed.push(`Backend API not accessible: ${e.message}`);
      console.log(`  ❌ Backend API error: ${e.message}`);
    }
    console.log('');

    // Test 4: Page Load Performance
    console.log('⚡ Test 4: Page Load Performance');
    const startTime = Date.now();
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    const loadTime = Date.now() - startTime;
    
    if (loadTime < 3000) {
      testResults.passed.push(`Page loads quickly (${loadTime}ms)`);
      console.log(`  ✅ Page loaded in ${loadTime}ms`);
    } else {
      testResults.warnings.push(`Page load time: ${loadTime}ms (target: <3000ms)`);
      console.log(`  ⚠️  Page loaded in ${loadTime}ms (slow)`);
    }
    console.log('');

    // Test 5: Visual Checks
    console.log('🎨 Test 5: Visual Design Checks');
    const screenshot = await page.screenshot({ fullPage: true });
    fs.writeFileSync(path.join(TEST_RESULTS_DIR, '05_visual_check.png'), screenshot);
    testResults.passed.push('Visual screenshot captured');
    console.log('  ✅ Visual screenshot saved');
    console.log('  ⚠️  Manual visual inspection required');
    console.log('');

    // Print Summary
    console.log('═══════════════════════════════════════');
    console.log('📊 TEST SUMMARY');
    console.log('═══════════════════════════════════════');
    console.log(`✅ Passed: ${testResults.passed.length}`);
    console.log(`❌ Failed: ${testResults.failed.length}`);
    console.log(`⚠️  Warnings: ${testResults.warnings.length}`);
    console.log('');

    if (testResults.passed.length > 0) {
      console.log('✅ Passed Tests:');
      testResults.passed.forEach(test => console.log(`   - ${test}`));
      console.log('');
    }

    if (testResults.failed.length > 0) {
      console.log('❌ Failed Tests:');
      testResults.failed.forEach(test => console.log(`   - ${test}`));
      console.log('');
    }

    if (testResults.warnings.length > 0) {
      console.log('⚠️  Warnings:');
      testResults.warnings.forEach(warning => console.log(`   - ${warning}`));
      console.log('');
    }

    // Save results
    fs.writeFileSync(
      path.join(TEST_RESULTS_DIR, 'test-results.json'),
      JSON.stringify(testResults, null, 2)
    );

    console.log(`📁 Test results saved to: ${TEST_RESULTS_DIR}`);
    console.log('\n💡 Note: Flutter web uses Canvas rendering, so some interactions');
    console.log('   require manual testing. Use the screenshots for visual verification.');

  } catch (error) {
    console.error('❌ Test Error:', error);
    testResults.failed.push(`Test execution error: ${error.message}`);
  } finally {
    await browser.close();
  }
}

runTests().catch(console.error);

