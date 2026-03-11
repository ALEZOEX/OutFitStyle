# Flutter Service Worker Bug Condition Exploration Test

## Overview

This test suite validates the bug condition for the Flutter Service Worker cache update issue. The test is designed to **FAIL on unfixed code**, which confirms that the bug exists.

## Bug Description

Users continue to see old version of the Flutter application (build 04dcf98) even after deploying a new version to the server. The Service Worker aggressively caches the application and does not update when new versions are deployed.

## Test Strategy

This is a **Bug Condition Exploration Test** following the bugfix workflow methodology:

1. **Deploy version 1** of Flutter app to test server
2. **Open application** in browser (registers Service Worker)
3. **Deploy version 2** with different FLUTTER_SERVICE_WORKER_VERSION
4. **Reload page** (F5 or Ctrl+R)
5. **Assert version 2 is loaded** (EXPECTED TO FAIL on unfixed code)

## Expected Outcome

**On UNFIXED code**: Test FAILS ❌
- Confirms the bug exists
- Documents counterexamples:
  - Service Worker remains in "waiting" state
  - Old version still loads from cache
  - flutter_service_worker.js cached with long TTL

**After implementing fix**: Test PASSES ✅
- Confirms the bug is resolved
- Validates requirements 2.1, 2.2, 2.3, 2.4

## Requirements Validated

- **1.1**: Browser continues loading old version after new deployment
- **1.2**: Service Worker doesn't detect changes
- **1.3**: Old client causes 401 errors with updated API
- **1.4**: Reload doesn't fetch new version
- **2.1**: Service Worker SHALL detect new version (expected behavior)
- **2.2**: Service Worker SHALL activate automatically (expected behavior)
- **2.3**: Client SHALL use latest version (expected behavior)
- **2.4**: User SHALL be notified or app reloads (expected behavior)

## Setup

### Prerequisites

- Node.js 18+ installed
- Flutter web build available at `client/build/web`

### Installation

```bash
cd tests/integration/service_worker_update
npm install
```

This will install:
- `jest` - Test framework
- `playwright` - Browser automation
- `fast-check` - Property-based testing library (for future tests)

### Build Flutter App

Before running the test, ensure you have a Flutter web build:

```bash
cd client
flutter build web
```

## Running the Test

### Run the bug condition exploration test:

```bash
npm test
```

### Run with verbose output:

```bash
npm test -- --verbose
```

### Watch mode (for development):

```bash
npm run test:watch
```

## Test Output

The test provides detailed console output showing:

1. Version 1 deployment and Service Worker registration
2. Version 2 deployment
3. Page reload
4. Service Worker state inspection
5. Assertion results with counterexamples

### Example Output (Expected Failure)

```
=== Starting Bug Condition Exploration Test ===

Step 1: Creating version 1 build...
✓ Version 1 build created with serviceWorkerVersion: 1000000001

Step 2: Starting test server with version 1...
✓ Test server started at http://localhost:8765

Step 3: Opening application in browser...
✓ Service Worker registered
✓ Version 1 Service Worker is active

Step 4: Deploying version 2...
✓ Version 2 build created with serviceWorkerVersion: 2000000002
✓ Test server restarted with version 2

Step 5: Reloading page...

Step 6: Checking Service Worker state...
Service Worker state: { active: {...}, waiting: {...} }

Step 7: Verifying loaded version...

=== Test Assertions ===

❌ EXPECTED FAILURE CONFIRMED ❌
This test failure proves the bug exists:
- Service Worker does not auto-update on deployment
- Old version still loads from cache
- User sees outdated application

Counterexamples documented:
1. Service Worker remains in "waiting" state after deployment
2. Old version (v1) still loads even after v2 is deployed
3. flutter_service_worker.js cached with long TTL
```

## Important Notes

### DO NOT FIX THE TEST

This test is designed to fail on unfixed code. If the test fails, it means:
1. The bug exists (correct)
2. The test correctly identifies the bug condition
3. You should proceed to implement the fix

### DO NOT FIX THE CODE YET

This is task 1 of the bugfix workflow. The code fix comes in task 3. This test:
1. Confirms the bug exists
2. Documents the expected behavior
3. Will validate the fix when it passes after implementation

## Next Steps

After this test fails (confirming the bug):

1. **Task 2**: Write preservation property tests (before fixing)
2. **Task 3**: Implement the fix
   - Add skipWaiting() to Service Worker
   - Add clients.claim() to Service Worker
   - Configure Cache-Control headers
   - Add update detection logic
3. **Task 3.6**: Re-run this test (should pass after fix)
4. **Task 3.7**: Verify preservation tests still pass

## Technical Details

### Test Implementation

- **Framework**: Jest with Playwright
- **Browser**: Chromium (headless)
- **Test Server**: Node.js HTTP server
- **Port**: 8765 (configurable)

### Test Approach

The test uses a scoped property-based testing approach:
- Focuses on the concrete failing case
- Simulates real deployment scenario
- Validates expected behavior properties
- Documents counterexamples when test fails

### Service Worker Inspection

The test inspects:
- Service Worker registration state
- Active/waiting/installing workers
- Service Worker script content
- Cache headers
- Version markers in code

## Troubleshooting

### Test hangs or times out

- Increase timeout in `jest.config.js`
- Check if port 8765 is available
- Ensure Flutter build exists at `client/build/web`

### Browser doesn't launch

- Install Playwright browsers: `npx playwright install chromium`
- Check Playwright installation: `npx playwright --version`

### Service Worker not registering

- Check browser console in headed mode
- Verify HTTPS or localhost (Service Workers require secure context)
- Clear browser cache between test runs

## References

- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Flutter Web Service Worker](https://docs.flutter.dev/platform-integration/web/service-worker)
- [Playwright Documentation](https://playwright.dev/)
