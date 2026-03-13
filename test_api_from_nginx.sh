#!/bin/sh

echo "Installing curl and jq..."
apk add --no-cache curl jq 2>/dev/null

echo ""
echo "=== Testing API from nginx container ==="
echo ""

# Generate unique email
TIMESTAMP=$(date +%s)
TEST_EMAIL="test_${TIMESTAMP}@example.com"
TEST_PASSWORD="TestPass123!"

echo "Step 1: Registering user ${TEST_EMAIL}..."
REGISTER_RESPONSE=$(curl -s -X POST http://api:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"display_name\":\"Test User\"}")

echo "Register response:"
echo "$REGISTER_RESPONSE" | jq .
echo ""

# Extract access_token
ACCESS_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.tokens.access_token // empty')

if [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR: No access_token in response"
  exit 1
fi

echo "Access token: ${ACCESS_TOKEN:0:50}..."
echo ""

# Test authenticated request
echo "Step 2: Testing authenticated request to /api/v1/wardrobe..."
WARDROBE_RESPONSE=$(curl -s -X GET http://api:8080/api/v1/wardrobe \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -w "\nHTTP_CODE:%{http_code}")

echo "Wardrobe response:"
echo "$WARDROBE_RESPONSE"
echo ""

if echo "$WARDROBE_RESPONSE" | grep -q "HTTP_CODE:200"; then
  echo "✓ SUCCESS: Bearer token authentication works!"
else
  echo "✗ FAILED: Bearer token authentication failed"
fi
