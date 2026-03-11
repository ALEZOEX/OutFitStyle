# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Service Worker Auto-Update on Deployment
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing case - deploy new version and verify old version still loads
  - Test implementation details from Bug Condition in design:
    - Deploy version 1 of Flutter app to test server
    - Open application in browser (register Service Worker)
    - Deploy version 2 with different FLUTTER_SERVICE_WORKER_VERSION
    - Reload page (F5 or Ctrl+R)
    - Assert that version 2 is loaded (from expectedBehavior: client uses new version)
    - Check Service Worker state in DevTools
    - Verify HTTP headers for flutter_service_worker.js
  - The test assertions should match the Expected Behavior Properties from design:
    - Service Worker detects new version
    - New Service Worker activates automatically
    - Client uses latest compatible version
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found:
    - Service Worker remains in "waiting" state
    - Old version still loads from cache
    - flutter_service_worker.js cached with long TTL
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Offline and Caching Functionality
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs (scenarios where no new version is deployed):
    - Test offline access to cached resources
    - Test fast loading from cache for current version
    - Test first-time Service Worker registration
    - Test caching of unchanged static resources (images, fonts)
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements:
    - For all scenarios where application version is current (NOT isBugCondition)
    - Assert offline access works
    - Assert cache improves loading performance
    - Assert Service Worker registers on first visit
    - Assert static resources cached correctly
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 3. Fix for Flutter Service Worker cache not updating on deployment

  - [x] 3.1 Add skipWaiting() to Service Worker install event
    - Locate flutter_service_worker.js or Flutter template used for generation
    - Add `self.skipWaiting()` in 'install' event handler
    - This forces new Service Worker to activate immediately instead of waiting
    - _Bug_Condition: isBugCondition(deployment) where deployment.newVersionDeployed = true AND NOT serviceWorkerUpdated_
    - _Expected_Behavior: Service Worker activates automatically (from design expectedBehavior)_
    - _Preservation: Offline access and caching for current version must continue (Preservation Requirements 3.1-3.4)_
    - _Requirements: 2.1, 2.2_

  - [x] 3.2 Add clients.claim() to Service Worker activate event
    - Add `self.clients.claim()` in 'activate' event handler
    - This forces new Service Worker to take control of all open pages immediately
    - _Bug_Condition: isBugCondition(deployment) where clientStillUsesOldVersion()_
    - _Expected_Behavior: Client uses latest compatible version (from design expectedBehavior)_
    - _Preservation: Existing client behavior for current version must continue (Preservation Requirements 3.2)_
    - _Requirements: 2.2, 2.3_

  - [x] 3.3 Configure Cache-Control headers for flutter_service_worker.js
    - Update server configuration (nginx.conf, .htaccess, or CDN settings)
    - Add headers for flutter_service_worker.js:
      ```
      Cache-Control: no-cache, no-store, must-revalidate
      Pragma: no-cache
      Expires: 0
      ```
    - Ensure browser always checks server for new Service Worker version
    - _Bug_Condition: isBugCondition(deployment) where Service Worker file cached by browser_
    - _Expected_Behavior: Service Worker detects new version (from design expectedBehavior)_
    - _Preservation: Caching of other static resources must continue (Preservation Requirements 3.4)_
    - _Requirements: 2.1_

  - [x] 3.4 Add update detection and notification logic
    - Update web/index.html or Service Worker registration file
    - Add listener for 'controllerchange' event
    - Implement automatic page reload or user notification when new Service Worker activates
    - Add periodic update check: call `registration.update()` at intervals
    - _Bug_Condition: isBugCondition(deployment) where user not aware of available update_
    - _Expected_Behavior: User notified or app reloads automatically (from design expectedBehavior requirement 2.4)_
    - _Preservation: Normal app loading without updates must continue (Preservation Requirements 3.2, 3.3)_
    - _Requirements: 2.4_

  - [x] 3.5 (Optional) Add Flutter UI for update notifications
    - In lib/main.dart, add snackbar or dialog for update notifications
    - Add "Обновить" button to manually apply update
    - Improve user experience for update process
    - _Expected_Behavior: User can manually trigger update (from design expectedBehavior)_
    - _Preservation: Normal app UI and functionality must continue (Preservation Requirements 3.2)_
    - _Requirements: 2.4_

  - [x] 3.6 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Service Worker Auto-Update on Deployment
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify:
      - New version loads after deployment
      - Service Worker activates without manual intervention
      - No 401 errors from API incompatibility
      - Client uses latest version
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 3.7 Verify preservation tests still pass
    - **Property 2: Preservation** - Offline and Caching Functionality
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm all preservation behaviors still work:
      - Offline access to cached resources
      - Fast loading from cache for current version
      - Service Worker registration on first visit
      - Static resource caching
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 4. Checkpoint - Ensure all tests pass
  - Run all unit tests for Service Worker functionality
  - Run all property-based tests for bug condition and preservation
  - Run integration tests for full deployment flow
  - Verify no 401 errors occur after Service Worker update
  - Verify offline functionality still works
  - Ensure all tests pass, ask the user if questions arise
