# Flutter Service Worker Auto-Update Scripts

## Overview

This directory contains scripts to enable automatic Service Worker updates for the Flutter web application.

## Problem

By default, Flutter Service Worker aggressively caches the application, causing users to see old versions even after deploying new builds. This leads to:
- Users stuck on outdated versions
- 401 errors due to API incompatibility
- Manual cache clearing required

## Solution

The `patch_service_worker.js` script patches the generated Service Worker to:
1. **skipWaiting()** - Activate new Service Worker immediately
2. **clients.claim()** - Take control of all pages immediately
3. **Message listener** - Respond to skipWaiting commands from client

Combined with update detection logic in `index.html`, this ensures users automatically get new versions.

## Usage

### Automatic (Recommended)

Add to `package.json` scripts:

```json
{
  "scripts": {
    "build:web": "flutter build web && node scripts/patch_service_worker.js"
  }
}
```

Then run:
```bash
npm run build:web
```

### Manual

After building Flutter web:

```bash
cd client
flutter build web
node scripts/patch_service_worker.js
```

### GitHub Actions

Update `.github/workflows/deploy-flutter-web.yml`:

```yaml
- name: Build Flutter web
  run: |
    cd client
    flutter build web --release
    node scripts/patch_service_worker.js
```

## How It Works

### 1. Build Process
```
flutter build web
  ↓
Generates flutter_service_worker.js
  ↓
patch_service_worker.js patches it
  ↓
Adds skipWaiting() and clients.claim()
```

### 2. Update Detection (index.html)
- Listens for `controllerchange` event → auto-reload
- Periodic update check every 60 seconds
- Check on page visibility change
- Send skipWaiting message to waiting Service Worker

### 3. Server Configuration (nginx.conf)
- `flutter_service_worker.js` served with `no-cache` headers
- Browser always checks server for new version
- Other static resources still cached for performance

## Verification

After deploying:

1. Open DevTools → Application → Service Workers
2. Deploy new version
3. Reload page or wait 60 seconds
4. New Service Worker should activate automatically
5. Page should reload with new version

## Troubleshooting

### Script fails to patch

**Error**: "Could not find install event listener"

**Solution**: Flutter may have changed Service Worker structure. Update regex patterns in `patch_service_worker.js`.

### Service Worker not updating

**Check**:
1. nginx serving `flutter_service_worker.js` with `no-cache` headers
2. Script ran after `flutter build web`
3. Browser DevTools shows new Service Worker detected

### Page not reloading

**Check**:
1. `index.html` has update detection script
2. Browser console shows "New Service Worker activated"
3. `controllerchange` event listener registered

## Files Modified

- `client/web/index.html` - Update detection logic
- `infrastructure/nginx/nginx.conf` - Cache-Control headers
- `client/scripts/patch_service_worker.js` - Service Worker patcher

## Requirements Validated

- ✅ 2.1: Service Worker detects new version
- ✅ 2.2: Service Worker activates automatically
- ✅ 2.3: Client uses latest version
- ✅ 2.4: User notified or app reloads automatically

## Preservation

Existing functionality preserved:
- ✅ 3.1: Offline access still works
- ✅ 3.2: Cache improves performance
- ✅ 3.3: First-time registration works
- ✅ 3.4: Static resources cached correctly
