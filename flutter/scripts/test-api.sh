#!/bin/bash

# XHS Flutter API Test Script

set -e

API_BASE="${API_BASE:-http://localhost:8080}"
COOKIE="${XHS_COOKIE:-}"

echo "🧪 Testing XHS Flutter API at $API_BASE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "🔗 $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$API_BASE$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_BASE$endpoint")
    fi
    
    # Split response and status code
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$status_code" -ge 200 ] && [ "$status_code" -lt 300 ]; then
        echo -e "${GREEN}✅ Success (Status: $status_code)${NC}"
        echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
    else
        echo -e "${RED}❌ Failed (Status: $status_code)${NC}"
        echo "$body"
    fi
}

# Test health check
test_endpoint "GET" "/health" "" "Health Check"

# Test configuration endpoints
test_endpoint "GET" "/api/config" "" "Get Configuration Status"

if [ -n "$COOKIE" ]; then
    echo -e "\n${YELLOW}Setting up configuration with provided cookie...${NC}"
    config_data=$(cat <<EOF
{
    "cookie": "$COOKIE",
    "python_path": "python3",
    "xhs_module_path": "../"
}
EOF
)
    test_endpoint "POST" "/api/config" "$config_data" "Set Configuration"
    
    # Test configuration status after setup
    test_endpoint "GET" "/api/config" "" "Get Configuration Status (After Setup)"
    
    echo -e "\n${YELLOW}Note: The following tests require a valid XHS cookie and may take some time...${NC}"
    echo "You can run specific endpoint tests by providing additional parameters:"
    echo "  XHS_NOTE_ID=<note_id> XHS_XSEC_TOKEN=<token> $0"
    echo "  XHS_USER_ID=<user_id> $0"
    echo "  XHS_SEARCH_KEYWORD=<keyword> $0"
    
    # Test search endpoints if keyword is provided
    if [ -n "$XHS_SEARCH_KEYWORD" ]; then
        test_endpoint "GET" "/api/notes/search?keyword=$XHS_SEARCH_KEYWORD&page=1&page_size=5" "" "Search Notes"
        test_endpoint "GET" "/api/users/search?keyword=$XHS_SEARCH_KEYWORD&page=1&page_size=5" "" "Search Users"
    fi
    
    # Test note endpoints if note ID and token are provided
    if [ -n "$XHS_NOTE_ID" ] && [ -n "$XHS_XSEC_TOKEN" ]; then
        test_endpoint "GET" "/api/notes/$XHS_NOTE_ID?xsec_token=$XHS_XSEC_TOKEN" "" "Get Note by ID"
        test_endpoint "GET" "/api/notes/$XHS_NOTE_ID/comments?xsec_token=$XHS_XSEC_TOKEN" "" "Get Note Comments"
    fi
    
    # Test user endpoints if user ID is provided
    if [ -n "$XHS_USER_ID" ]; then
        test_endpoint "GET" "/api/users/$XHS_USER_ID" "" "Get User Info"
        test_endpoint "GET" "/api/users/$XHS_USER_ID/notes" "" "Get User Notes"
    fi
    
    # Test feed endpoints
    test_endpoint "GET" "/api/feed/recommend" "" "Get Recommend Feed"
    test_endpoint "GET" "/api/feed/food" "" "Get Food Feed"
    
else
    echo -e "\n${YELLOW}⚠️  No cookie provided. Some tests will be skipped.${NC}"
    echo "To test with a real cookie, run:"
    echo "  XHS_COOKIE='your_cookie_here' $0"
fi

echo -e "\n${GREEN}🎉 API testing completed!${NC}"
echo -e "\n${YELLOW}📚 API Documentation:${NC}"
echo "  Health: GET /health"
echo "  Config: GET|POST /api/config"
echo "  Notes: GET /api/notes/{id}, /api/notes/search, /api/notes/{id}/comments"
echo "  Users: GET /api/users/{id}, /api/users/search, /api/users/{id}/notes"
echo "  Feeds: GET /api/feed/{type}"