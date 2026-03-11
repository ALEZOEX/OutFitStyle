#!/usr/bin/env node

/**
 * Post-build script to patch Flutter Service Worker with auto-update functionality
 *
 * This script adds:
 * 1. skipWaiting() to install event - forces immediate activation
 * 2. clients.claim() to activate event - takes control of all pages immediately
 * 3. Message listener for skipWaiting command from client
 *
 * Run after: flutter build web
 */

const fs = require('fs');
const path = require('path');

const SERVICE_WORKER_PATH = path.join(__dirname, '../build/web/flutter_service_worker.js');

console.log('🔧 Patching Service Worker for auto-update...');

try {
  // Read the generated Service Worker file
  let swContent = fs.readFileSync(SERVICE_WORKER_PATH, 'utf-8');

  // Check if already patched
  if (swContent.includes('// PATCHED: Auto-update enabled')) {
    console.log('✓ Service Worker already patched');
    process.exit(0);
  }

  // Add skipWaiting() to install event
  const installEventPattern = /self\.addEventListener\("install",\s*function\s*\([^)]*\)\s*{/;

  if (installEventPattern.test(swContent)) {
    swContent = swContent.replace(
      installEventPattern,
      match => `${match}\n  // PATCHED: Auto-update enabled - skip waiting\n  self.skipWaiting();`
    );
    console.log('✓ Added skipWaiting() to install event');
  } else {
    console.warn('⚠️  Could not find install event listener');
  }

  // Add clients.claim() to activate event
  const activateEventPattern = /self\.addEventListener\("activate",\s*function\s*\([^)]*\)\s*{/;

  if (activateEventPattern.test(swContent)) {
    swContent = swContent.replace(
      activateEventPattern,
      match => `${match}\n  // PATCHED: Auto-update enabled - claim clients\n  self.clients.claim();`
    );
    console.log('✓ Added clients.claim() to activate event');
  } else {
    console.warn('⚠️  Could not find activate event listener');
  }

  // Add message listener for skipWaiting command
  const messageListener = `
// PATCHED: Listen for skipWaiting message from client
self.addEventListener('message', function(event) {
  if (event.data === 'skipWaiting') {
    console.log('Received skipWaiting message, activating new Service Worker...');
    self.skipWaiting();
  }
});
`;

  swContent += messageListener;
  console.log('✓ Added message listener for skipWaiting command');

  // Write the patched Service Worker back
  fs.writeFileSync(SERVICE_WORKER_PATH, swContent, 'utf-8');

  console.log('✅ Service Worker patched successfully');
  console.log(`   File: ${SERVICE_WORKER_PATH}`);

} catch (error) {
  console.error('❌ Error patching Service Worker:', error.message);
  process.exit(1);
}
