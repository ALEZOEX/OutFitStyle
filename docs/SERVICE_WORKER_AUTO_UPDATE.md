# Service Worker Auto-Update Implementation

## Overview

This document describes the implementation of automatic Service Worker updates for the Flutter web application, fixing the issue where users continued to see old versions after deployment.

## Problem Statement

**Bug**: Users see old version (build 04dcf98) even after deploying new version to server.

**Symptoms**:
- Browser loads cached version from Service Worker
- 401 errors due to API incompatibility
- Users must manually clear Service Worker cache
- Page reload doesn't fetch new version

**Root Causes**:
1. Service Worker doesn't call `skipWaiting()` - stays in "waiting" state
2. Service Worker doesn't call `clients.claim()` - doesn't control existing pages
3. `flutter_service_worker.js` cached with long TTL by browser
4. No update detection logic in client

## Solution Architecture

### 1. Service Worker Patching

**File**: `client/scripts/patch_service_worker.js`

Post-build script that patches generated Service Worker:

```javascript
// Install event - activate immediately
self.addEventListener("install", function(event) {
  self.skipWaiting(); // ← Added
  //... rest of install logic
});

// Activate event - take control immediately
self.addEventListener("activate", function(event) {
  self.clients.claim(); // ← Added
  // ... rest of activate logic
});

// Message listener - respond to skipWaiting commands
self.addEventListener('message', function(event) {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});
```

### 2. Update Detection Logic

**File**: `client/web/index.html`

Client-side logic to detect and apply updates:

```javascript
// Auto-reload when new Service Worker activates
navigator.serviceWorker.addEventListener('controllerchange', () => {
  window.location.reload();
});

// Periodic update check (every 60 seconds)
setInterval(() => {
  registration.update();
}, 60000);

// Check on page visibility change
document.addEventListener('visibilitychange', () => {
  if (!document.hidden) {
    registration.update();
  }
});

// Activate waiting Service Worker
if (registration.waiting) {
  registration.waiting.postMessage('skipWaiting');
}
```

### 3. Server Configuration

**File**: `infrastructure/nginx/nginx.conf`

Prevent browser caching of Service Worker file:

```nginx
location = /flutter_service_worker.js {
  add_header Cache-Control "no-cache, no-store, must-revalidate" always;
  add_header Pragma "no-cache" always;
  add_header Expires "0" always;
  try_files $uri =404;
}
```

## Deployment Process

### Local Development

```bash
cd client
flutter build web
node scripts/patch_service_worker.js
```

### Production Deployment

1. **Build Flutter web**:
   ```bash
   cd client
   flutter build web --release
   ```

2. **Patch Service Worker**:
   ```bash
   node scripts/patch_service_worker.js
   ```

3. **Upload to server**:
   ```bash
   scp -r build/web/* root@144.31.234.69:/root/OutFitStyle/client/build/web/
   ```

4. **Restart nginx**:
   ```bash
   ssh root@144.31.234.69
   cd /root/OutFitStyle
   docker-compose restart nginx
   ```

### GitHub Actions (Automated)

Update `.github/workflows/deploy-flutter-web.yml`:

```yaml
- name: Build Flutter web
  run: |
    cd client
    flutter build web --release
    node scripts/patch_service_worker.js

- name: Deploy to server
  run: |
    scp -r client/build/web/* root@${{ secrets.SERVER_IP }}:/root/OutFitStyle/client/build/web/
    ssh root@${{ secrets.SERVER_IP }} "cd /root/OutFitStyle && docker-compose restart nginx"
```

## User Experience

### Before Fix

1. User opens app → sees old version (build 04dcf98)
2. New version deployed to server
3. User reloads page → still sees old version
4. User gets 401 errors
5. User must manually clear Service Worker cache

### After Fix

1. User opens app → sees current version
2. New version deployed to server
3. Service Worker detects update automatically
4. New Service Worker activates immediately
5. Page reloads automatically with new version
6. User sees updated app without manual intervention

## Update Flow Diagram

```
New version deployed
        ↓
Browser checks flutter_service_worker.js (no-cache)
        ↓
New Service Worker detected
        ↓
Install event → skipWaiting()
        ↓
Activate event → clients.claim()
        ↓
controllerchange event fired
        ↓
Page reloads automatically
        ↓
User sees new version
```

## Verification Steps

### 1. Check Service Worker Patch

```bash
cd client/build/web
grep "PATCHED: Auto-update enabled" flutter_service_worker.js
```

Should output:
```
// PATCHED: Auto-update enabled - skip waiting
// PATCHED: Auto-update enabled - claim clients
// PATCHED: Listen for skipWaiting message from client
```

### 2. Check nginx Configuration

```bash
curl -I https://app.outfitstyle.ru/flutter_service_worker.js
```

Should include:
```
Cache-Control: no-cache, no-store, must-revalidate
Pragma: no-cache
Expires: 0
```

### 3. Test Update Flow

1. Open app in browser
2. Open DevTools → Application → Service Workers
3. Deploy new version
4. Wait 60 seconds or reload page
5. Check console for: "New Service Worker activated, reloading page..."
6. Verify new version loads

## Troubleshooting

### Service Worker Not Updating

**Symptoms**: Old version still loads after deployment

**Checks**:
1. Verify patch script ran: `grep PATCHED client/build/web/flutter_service_worker.js`
2. Check nginx headers: `curl -I https://app.outfitstyle.ru/flutter_service_worker.js`
3. Clear browser cache completely
4. Check DevTools → Application → Service Workers for errors

**Solutions**:
- Re-run patch script: `node client/scripts/patch_service_worker.js`
- Restart nginx: `docker-compose restart nginx`
- Hard refresh: Ctrl+Shift+R
- Unregister Service Worker manually in DevTools

### Page Not Reloading

**Symptoms**: New Service Worker activates but page doesn't reload

**Checks**:
1. Check browser console for "controllerchange" event
2. Verify `index.html` has update detection script
3. Check for JavaScript errors

**Solutions**:
- Verify `index.html` deployed correctly
- Check browser console for errors
- Manually reload page

### 401 Errors Persist

**Symptoms**: Still getting 401 errors after update

**Possible Causes**:
1. JWT secret changed - users need to re-login
2. API breaking changes - check API compatibility
3. Old version still cached - clear all browser data

**Solutions**:
- Users re-login to get new JWT tokens
- Check API version compatibility
- Clear all site data in DevTools

## Performance Impact

### Positive

- ✅ Users always get latest version
- ✅ No manual cache clearing needed
- ✅ Automatic updates within 60 seconds
- ✅ Offline functionality preserved

### Neutral

- ⚪ Periodic update checks (60s interval) - minimal network overhead
- ⚪ Auto-reload on update - brief interruption for user

### Monitoring

Monitor these metrics:
- Service Worker activation time
- Update detection latency
- Page reload frequency
- User complaints about old versions (should decrease to zero)

## Requirements Validated

### Bug Fix (Requirements 2.1-2.4)

- ✅ **2.1**: Service Worker detects new version automatically
- ✅ **2.2**: Service Worker activates without manual intervention
- ✅ **2.3**: Client uses latest compatible version
- ✅ **2.4**: Page reloads automatically when update available

### Preservation (Requirements 3.1-3.4)

- ✅ **3.1**: Offline access to cached resources still works
- ✅ **3.2**: Cache improves loading performance for current version
- ✅ **3.3**: Service Worker registers correctly on first visit
- ✅ **3.4**: Static resources (images, fonts) still cached for performance

## Testing

### Manual Testing

See: `tests/integration/service_worker_update/MANUAL_TEST_INSTRUCTIONS.md`

### Automated Testing

```bash
cd tests/integration/service_worker_update
npm install
npm test
```

**Expected Results**:
- Bug condition test: PASSES (after fix)
- Preservation tests: PASSES (no regressions)

## Rollback Plan

If issues occur:

1. **Revert nginx config**:
   ```bash
   git revert <commit-hash>
   docker-compose restart nginx
   ```

2. **Revert index.html**:
   ```bash
   git checkout HEAD~1 client/web/index.html
   flutter build web
   ```

3. **Skip patch script**:
   ```bash
   flutter build web
   # Don't run patch_service_worker.js
   ```

4. **Clear all Service Workers**:
   - Users visit: `https://app.outfitstyle.ru/?clear-sw=1`
   - Add script to unregister Service Worker

## Future Improvements

1. **Version notification UI**: Show snackbar instead of auto-reload
2. **Update scheduling**: Allow users to defer updates
3. **Progressive rollout**: Deploy to percentage of users first
4. **Telemetry**: Track update success rate
5. **Fallback mechanism**: Detect failed updates and retry

## References

- [Service Worker Lifecycle](https://developers.google.com/web/fundamentals/primers/service-workers/lifecycle)
- [skipWaiting() API](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerGlobalScope/skipWaiting)
- [clients.claim() API](https://developer.mozilla.org/en-US/docs/Web/API/Clients/claim)
- [Flutter Web Service Worker](https://docs.flutter.dev/platform-integration/web/service-worker)

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review test results in `tests/integration/service_worker_update/`
3. Check browser DevTools console for errors
4. Review nginx logs: `docker-compose logs nginx`
