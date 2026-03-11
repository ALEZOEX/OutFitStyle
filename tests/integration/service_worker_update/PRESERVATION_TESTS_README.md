# Service Worker Preservation Property Tests

## Overview

This document describes the preservation property tests created for Task 2 of the flutter-service-worker-cache-fix bugfix spec.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

## Purpose

These tests validate that existing correct behavior is preserved after implementing the Service Worker update fix. They test scenarios where NO new version is deployed (NOT isBugCondition), ensuring that:

1. Offline access continues to work
2. Caching improves performance for current version
3. Service Worker registers on first visit
4. Static resources are cached correctly

## Test File

`service_worker_preservation.test.js`

## Test Properties

### Property 1: Offline Access Preservation (Requirement 3.1)

**Validates: Requirement 3.1**

Tests that when a user works with the application in offline mode, the Service Worker continues to provide access to cached resources.

**Test Steps:**
1. Prepare build and start server
2. Open application and register Service Worker
3. Verify resources are cached
4. Simulate offline mode
5. Reload page and verify it loads from cache
6. Verify page content is accessible

**Expected Outcome:** PASS on unfixed code - offline access works correctly

### Property 2: Cache Performance Preservation (Requirement 3.2)

**Validates: Requirement 3.2**

Tests that when the current version is already cached and no new version is deployed, the Service Worker continues to use cache for fast loading.

**Test Steps:**
1. Prepare build and start server
2. First visit - measure load time
3. Second visit - measure cached load time
4. Verify Service Worker is active
5. Verify resources are cached

**Expected Outcome:** PASS on unfixed code - cache improves loading performance

### Property 3: First-Time Registration Preservation (Requirement 3.3)

**Validates: Requirement 3.3**

Tests that when a user visits the application for the first time, the Service Worker registers and caches necessary resources for PWA functionality.

**Test Steps:**
1. Prepare build and start server
2. Open application in fresh context (simulating first visit)
3. Verify no Service Worker exists before navigation
4. Navigate to application
5. Wait for Service Worker registration
6. Verify Service Worker is registered and activated
7. Verify resources are cached

**Expected Outcome:** PASS on unfixed code - Service Worker registers correctly on first visit

### Property 4: Static Resource Caching Preservation (Requirement 3.4)

**Validates: Requirement 3.4**

Tests that when static resources (images, fonts, CSS, JS) have not changed, the Service Worker continues to use them from cache for performance optimization.

**Test Steps:**
1. Prepare build and start server
2. Open application and register Service Worker
3. Get all cached resources
4. Identify static resources by type (images, fonts, styles, scripts, data)
5. Verify static resources are cached
6. Reload page and verify resources load from cache

**Expected Outcome:** PASS on unfixed code - static resources are cached correctly

### Property-Based Test: Preservation Across Multiple Scenarios

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

Uses property-based testing with fast-check to generate various scenarios and verify that preservation properties hold across all of them.

**Scenarios Generated:**
- isFirstVisit: boolean
- isOffline: boolean
- hasCache: boolean
- resourceType: 'html' | 'js' | 'css' | 'image' | 'font'

**Test Runs:** 20 random scenarios

**Expected Outcome:** PASS on unfixed code - preservation logic is consistent across all scenarios

## Running the Tests

### Prerequisites

Install dependencies:
```bash
cd tests/integration/service_worker_update
npm install
```

### Run Preservation Tests

```bash
npm test -- service_worker_preservation.test.js
```

### Run All Tests

```bash
npm test
```

## Expected Results on Unfixed Code

All preservation tests should **PASS** on the unfixed code. This confirms:

1. ✅ Offline access works correctly
2. ✅ Cache improves loading performance
3. ✅ Service Worker registers on first visit
4. ✅ Static resources are cached correctly

These tests establish the baseline behavior that must be preserved after implementing the fix.

## After Implementing the Fix

After implementing the fix in Task 3, these same tests should continue to **PASS**, confirming that:

- The fix does not break existing offline functionality
- The fix does not break caching performance
- The fix does not break first-time registration
- The fix does not break static resource caching

## Test Framework

- **Test Runner:** Jest with ES modules
- **Browser Automation:** Playwright (Chromium)
- **Property-Based Testing:** fast-check
- **Test Port:** 8766 (different from bug condition test port 8765)

## Notes

- These tests use a separate test port (8766) to avoid conflicts with the bug condition tests
- The tests create temporary build directories in `test_builds_preservation/`
- The tests clean up after themselves by removing temporary directories
- The tests simulate various browser states (online/offline, first visit/repeat visit)
- The property-based test provides stronger guarantees by testing multiple scenarios

## Task Completion Criteria

Task 2 is complete when:

1. ✅ Preservation tests are written
2. ✅ Tests cover all preservation requirements (3.1, 3.2, 3.3, 3.4)
3. ✅ Tests use property-based testing for stronger guarantees
4. ⏳ Tests are run on unfixed code (pending npm install resolution)
5. ⏳ Tests PASS on unfixed code (expected outcome)

## Known Issues

- Network connectivity issues may prevent npm install from completing
- If dependencies are already installed from Task 1, the tests can be run immediately
- The tests are designed to work with the existing Flutter web build in `client/build/web`
