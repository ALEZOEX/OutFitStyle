/**
 * Bug Condition Exploration Test for Flutter Service Worker Cache Update Issue
 *
 * **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4**
 *
 * **Property 1: Bug Condition** - Service Worker Auto-Update on Deployment
 *
 * CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists
 * DO NOT attempt to fix the test or the code when it fails
 *
 * This test encodes the expected behavior:
 * - Service Worker detects new version
 * - New Service Worker activates automatically
 * - Client uses latest compatible version
 *
 * When this test passes after implementing the fix, it confirms the bug is resolved.
 */

import { test, expect, describe, beforeAll, afterAll } from '@jest/globals';
import { chromium } from 'playwright';
import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import http from 'http';
import { createReadStream } from 'fs';
import { stat } from 'fs/promises';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Test configuration
const TEST_PORT = 8765;
const TEST_URL = `http://localhost:${TEST_PORT}`;
const BUILD_DIR = path.join(__dirname, '../../../client/build/web');
const TEST_BUILD_DIR = path.join(__dirname, 'test_builds');

describe('Service Worker Bug Condition Exploration', () => {
  let browser;
  let server;

  beforeAll(async () => {
    // Launch browser
    browser = await chromium.launch({ headless: true });

    // Create test build directories
    await fs.mkdir(TEST_BUILD_DIR, { recursive: true });
  });

  afterAll(async () => {
    if (browser) {
      await browser.close();
    }
    if (server) {
      server.close();
    }
    // Cleanup test buil
s.setHeader('Access-Control-Allow-Headers', 'Content-Type');

      // CRITICAL: No cache headers for Service Worker file
      // This simulates the bug condition where flutter_service_worker.js is cached
      if (req.url.includes('flutter_service_worker.js')) {
        // Simulating aggressive caching (the bug)
        res.setHeader('Cache-Control', 'public, max-age=31536000');
      } else if (req.url.includes('index.html')) {
        res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
      }

      try {
        const stats = await stat(filePath);
        if (stats.isFile()) {
          const ext = path.extname(filePath);
          const contentTypes = {
            '.html': 'text/html',
            '.js': 'application/javascript',
            '.json': 'application/json',
            '.css': 'text/css',
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.svg': 'image/svg+xml',
            '.wasm': 'application/wasm'
          };
          res.setHeader('Content-Type', contentTypes[ext] || 'application/octet-stream');
          createReadStream(filePath).pipe(res);
        } else {
          res.writeHead(404);
          res.end('Not found');
        }
      } catch (err) {
        res.writeHead(404);
        res.end('Not found');
      }
    });
  }

  /**
   * Helper function to modify Service Worker version in build
   */
  async function createBuildWithVersion(sourceDir, targetDir, version) {
    // Copy build directory
    await fs.cp(sourceDir, targetDir, { recursive: true });

    // Modify flutter_bootstrap.js to change serviceWorkerVersion
    const bootstrapPath = path.join(targetDir, 'flutter_bootstrap.js');
    let bootstrapContent = await fs.readFile(bootstrapPath, 'utf-8');

    // Replace serviceWorkerVersion with new version
    bootstrapContent = bootstrapContent.replace(
      /serviceWorkerVersion:\s*"[^"]+"/,
      `serviceWorkerVersion: "${version}"`
    );

    await fs.writeFile(bootstrapPath, bootstrapContent);

    // Also modify flutter_service_worker.js to add a version marker
    const swPath = path.join(targetDir, 'flutter_service_worker.js');
    let swContent = await fs.readFile(swPath, 'utf-8');

    // Add version comment at the top
    swContent = `// VERSION: ${version}\n${swContent}`;

    await fs.writeFile(swPath, swContent);

    return targetDir;
  }

  /**
   * Helper function to get Service Worker version from page
   */
  async function getServiceWorkerVersion(page) {
    return await page.evaluate(() => {
      return new Promise((resolve) => {
        if (!navigator.serviceWorker.controller) {
          resolve(null);
          return;
        }

        // Get the active service worker's script URL
        navigator.serviceWorker.getRegistration().then(registration => {
          if (registration && registration.active) {
            resolve(registration.active.scriptURL);
          } else {
            resolve(null);
          }
        });
      });
    });
  }

  /**
   * Helper function to get Service Worker state
   */
  async function getServiceWorkerState(page) {
    return await page.evaluate(() => {
      return new Promise((resolve) => {
        navigator.serviceWorker.getRegistration().then(registration => {
          if (!registration) {
            resolve({ active: null, waiting: null, installing: null });
            return;
          }

          resolve({
            active: registration.active ? {
              state: registration.active.state,
              scriptURL: registration.active.scriptURL
            } : null,
            waiting: registration.waiting ? {
              state: registration.waiting.state,
              scriptURL: registration.waiting.scriptURL
            } : null,
            installing: registration.installing ? {
              state: registration.installing.state,
              scriptURL: registration.installing.scriptURL
            } : null
          });
        });
      });
    });
  }

  /**
   * Helper function to check if a specific version is loaded
   */
  async function getLoadedVersion(page) {
    return await page.evaluate(() => {
      // Check if _flutter.buildConfig exists and return serviceWorkerVersion
      if (window._flutter && window._flutter.loader) {
        return window._flutter.buildConfig?.serviceWorkerVersion || 'unknown';
      }
      return 'unknown';
    });
  }

  test('Bug Condition: Service Worker does not auto-update on deployment', async () => {
    console.log('\n=== Starting Bug Condition Exploration Test ===\n');

    // Step 1: Create version 1 build
    console.log('Step 1: Creating version 1 build...');
    const v1BuildDir = path.join(TEST_BUILD_DIR, 'v1');
    await createBuildWithVersion(BUILD_DIR, v1BuildDir, '1000000001');
    console.log('✓ Version 1 build created with serviceWorkerVersion: 1000000001');

    // Step 2: Start server with version 1
    console.log('\nStep 2: Starting test server with version 1...');
    server = createTestServer(v1BuildDir);
    await new Promise((resolve) => {
      server.listen(TEST_PORT, resolve);
    });
    console.log(`✓ Test server started at ${TEST_URL}`);

    // Step 3: Open application in browser (register Service Worker)
    console.log('\nStep 3: Opening application in browser...');
    const context = await browser.newContext();
    const page = await context.newPage();

    await page.goto(TEST_URL, { waitUntil: 'networkidle' });

    // Wait for Service Worker to register
    await page.waitForTimeout(2000);

    const v1SwState = await getServiceWorkerState(page);
    console.log('✓ Service Worker registered:', JSON.stringify(v1SwState, null, 2));

    expect(v1SwState.active).not.toBeNull();
    console.log('✓ Version 1 Service Worker is active');

    // Step 4: Stop server and deploy version 2
    console.log('\nStep 4: Deploying version 2...');
    server.close();
    await new Promise(resolve => setTimeout(resolve, 500));

    const v2BuildDir = path.join(TEST_BUILD_DIR, 'v2');
    await createBuildWithVersion(BUILD_DIR, v2BuildDir, '2000000002');
    console.log('✓ Version 2 build created with serviceWorkerVersion: 2000000002');

    // Start server with version 2
    server = createTestServer(v2BuildDir);
    await new Promise((resolve) => {
      server.listen(TEST_PORT, resolve);
    });
    console.log('✓ Test server restarted with version 2');

    // Step 5: Reload page (F5 or Ctrl+R)
    console.log('\nStep 5: Reloading page...');
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    // Step 6: Check Service Worker state
    console.log('\nStep 6: Checking Service Worker state...');
    const v2SwState = await getServiceWorkerState(page);
    console.log('Service Worker state after reload:', JSON.stringify(v2SwState, null, 2));

    // Step 7: Verify which version is loaded
    console.log('\nStep 7: Verifying loaded version...');

    // Check the Service Worker script content
    const swScriptURL = v2SwState.active?.scriptURL;
    if (swScriptURL) {
      const swContent = await page.evaluate(async (url) => {
        const response = await fetch(url);
        const text = await response.text();
        return text.substring(0, 200); // Get first 200 chars to check version comment
      }, swScriptURL);
      console.log('Service Worker script content (first 200 chars):', swContent);
    }

    // EXPECTED BEHAVIOR (what should happen after fix):
    // - Service Worker detects new version (requirement 2.1)
    // - New Service Worker activates automatically (requirement 2.2)
    // - Client uses latest compatible version (requirement 2.3)

    console.log('\n=== Test Assertions ===\n');

    // Assertion 1: New Service Worker should be detected
    console.log('Assertion 1: Checking if new Service Worker was detected...');

    // In the bug condition, the Service Worker will either:
    // - Stay in "waiting" state (not activated)
    // - Not be detected at all (old version still active)

    // This assertion expects the new version to be active (WILL FAIL on unfixed code)
    try {
      // Check if there's a waiting Service Worker (indicates update detected but not activated)
      if (v2SwState.waiting) {
        console.log('❌ EXPECTED FAILURE: New Service Worker detected but in WAITING state');
        console.log('   This confirms the bug: Service Worker not activating automatically');
        console.log('   Counterexample: Service Worker remains in "waiting" state');
        expect(v2SwState.waiting).toBeNull(); // This will fail, proving the bug
      }

      // Check if the active Service Worker is still version 1
      const swContent = await page.evaluate(async () => {
        const response = await fetch('/flutter_service_worker.js');
        const text = await response.text();
        return text.substring(0, 50);
      });

      console.log('Current Service Worker content:', swContent);

      // This assertion expects version 2 to be loaded (WILL FAIL on unfixed code)
      expect(swContent).toContain('VERSION: 2000000002');

      console.log('✓ Test PASSED: New Service Worker activated automatically');

    } catch (error) {
      console.log('\n❌ EXPECTED FAILURE CONFIRMED ❌');
      console.log('This test failure proves the bug exists:');
      console.log('- Service Worker does not auto-update on deployment');
      console.log('- Old version still loads from cache');
      console.log('- User sees outdated application');
      console.log('\nCounterexamples documented:');
      console.log('1. Service Worker remains in "waiting" state after deployment');
      console.log('2. Old version (v1) still loads even after v2 is deployed');
      console.log('3. flutter_service_worker.js cached with long TTL');
      console.log('\nThis confirms requirements 1.1, 1.2, 1.4 are violated.');
      console.log('Expected behavior (requirements 2.1, 2.2, 2.3) is NOT satisfied.\n');

      throw error; // Re-throw to mark test as failed
    }

    await context.close();
  });
});
