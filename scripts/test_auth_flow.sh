#!/bin/bash
# Test authentication flow on production server
# Usage: ./scripts/test_auth_flow.sh <server_url>
# Example: ./scripts/test_auth_flow.sh https://app.outfitstyle.ru

if [ -z "$1" ]; then
  echo "Usage: ./test_auth_flow.sh <server_url>"
  echo "Example: ./test_auth_flow.sh https://app.outfitstyle.ru"
  exit 1
fi

SERVER_URL="$1"

echo "=== Testing Authentication Flow ==="
echo ""

# Step 1: Register a new test user
echo "Step 1: Registering test user..."
TIMESTAMP=$(date +%s)
TEST_EMAIL="test_${TIMESTAMP}@example.com"
TEST_PASSWORD="TestPass123!"

REGISTER_RESPONSE=$(curl -s -X POST "${SERVER_URL}/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"display_name\":\"Test User\"}")

echo "Register response: $REGISTER_RESPONSE"
echo ""

# Extract access_token from response
ACCESS_TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR: No access_token in register response"
  exit 1
fi

echo "Access token received: ${ACCESS_TOKEN:0:50}..."
echo ""

# Step 2: Test authenticated request with Bearer token
echo "Step 2: Testing authenticated request to /api/v1/wardrobe..."
WARDROBE_RESPONSE=$(curl -s -X GET "${SERVER_URL}/api/v1/wardrobe" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -w "\nHTTP_CODE:%{http_code}")

echo "Wardrobe response: $WARDROBE_RESPONSE"
echo ""

# Check if request was successful
if echo "$WARDROBE_RESPONSE" | grep -q "HTTP_CODE:200"; then
  echo "✓ SUCCESS: Bearer token authentication is working!"
else
  echo "✗ FAILED: Bearer token authentication failed"
  echo "Response: $WARDROBE_RESPONSE"
fi
