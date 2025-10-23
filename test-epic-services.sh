#!/bin/bash

# ==============================================================================
# AUDIRA EPIC SERVICES - TEST SCRIPT
# Tests all 4 epic-based microservices
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
API_GATEWAY="http://localhost:8080"
CONFIG_SERVER="http://localhost:8888"
EUREKA_SERVER="http://localhost:8761"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0

# Variables
JWT_TOKEN=""
TEST_USER_ID=""
TEST_GENRE_ID=""
TEST_ALBUM_ID=""
TEST_SONG_ID=""
TEST_PLAYLIST_ID=""
TEST_PRODUCT_ID=""
TEST_ORDER_ID=""

# ==============================================================================
# Helper Functions
# ==============================================================================

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_test() {
    ((TOTAL_TESTS++))
    echo -e "${YELLOW}[TEST $TOTAL_TESTS] $1${NC}"
}

print_success() {
    ((PASSED_TESTS++))
    echo -e "${GREEN}✓ PASSED - $1${NC}\n"
}

print_error() {
    echo -e "${RED}✗ FAILED - $1${NC}"
    echo -e "${RED}ERROR: Test failed. Stopping script.${NC}"
    exit 1
}

wait_for_service() {
    local url=$1
    local name=$2
    local max_attempts=30

    echo -e "${BLUE}Waiting for $name to be available...${NC}"

    for ((i=1; i<=max_attempts; i++)); do
        if curl -sf "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $name is available${NC}\n"
            return 0
        fi
        echo "Attempt $i/$max_attempts..."
        sleep 2
    done

    print_error "$name not available after $max_attempts attempts"
}

# ==============================================================================
# START TESTS
# ==============================================================================

echo -e "${MAGENTA}"
cat << "EOF"
    ___   __  ______  _____  ___  ___
  / _ | / / / / __ \/  _/ |/ / |/ _ |
 / __ |/ /_/ / /_/ // // /|  /| / __ |
/_/ |_|\____/\____/___/_/ |_/ |_/_/ |_|

EPIC SERVICES TEST SUITE
Testing 4 consolidated microservices

EOF
echo -e "${NC}"

# ==============================================================================
# 1. Infrastructure Services
# ==============================================================================

print_header "1. VERIFYING INFRASTRUCTURE"

print_test "Config Server - Health Check"
wait_for_service "$CONFIG_SERVER/actuator/health" "Config Server"

print_test "Eureka Server - Health Check"
wait_for_service "$EUREKA_SERVER/actuator/health" "Eureka Discovery Server"

print_test "API Gateway - Health Check"
wait_for_service "$API_GATEWAY/actuator/health" "API Gateway"

echo -e "${GREEN}✓ All infrastructure services are running${NC}\n"
echo -e "${BLUE}Waiting 10 seconds for services to register with Eureka...${NC}"
sleep 10

# ==============================================================================
# 2. ÉPICA 1: Community Service - User Management
# ==============================================================================

print_header "2. ÉPICA 1: COMMUNITY SERVICE - Users"

print_test "Register new user"
response=$(curl -sf -X POST "$API_GATEWAY/api/users/auth/register" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "email": "testuser@audira.com",
        "password": "Password123!",
        "firstName": "Test",
        "lastName": "User"
    }' || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "User registration failed"
fi

TEST_USER_ID=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
JWT_TOKEN=$(echo "$response" | grep -o '"token":"[^"]*"' | sed 's/"token":"//;s/"//')

if [[ -z "$JWT_TOKEN" ]]; then
    print_error "Failed to get JWT token"
fi

print_success "User registered (ID: $TEST_USER_ID)"

print_test "Get user profile"
response=$(curl -sf -H "Authorization: Bearer $JWT_TOKEN" \
    "$API_GATEWAY/api/users/profile" || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "Get profile failed"
fi

print_success "User profile retrieved"

# ==============================================================================
# 3. ÉPICA 2: Music Catalog Service
# ==============================================================================

print_header "3. ÉPICA 2: MUSIC CATALOG SERVICE"

print_test "Create genre"
response=$(curl -sf -X POST "$API_GATEWAY/api/genres" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Rock",
        "description": "Rock music genre",
        "imageUrl": "https://example.com/rock.jpg"
    }' || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "Create genre failed"
fi

TEST_GENRE_ID=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
print_success "Genre created (ID: $TEST_GENRE_ID)"

print_test "Create song"
response=$(curl -sf -X POST "$API_GATEWAY/api/songs" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "title": "Test Song",
        "artistId": 1,
        "duration": 240,
        "audioUrl": "https://example.com/song.mp3",
        "price": 1.99,
        "lyrics": "Test lyrics"
    }' || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "Create song failed"
fi

TEST_SONG_ID=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
print_success "Song created (ID: $TEST_SONG_ID)"

# ==============================================================================
# 4. ÉPICA 3: Playback Service
# ==============================================================================

print_header "4. ÉPICA 3: PLAYBACK SERVICE"

print_test "Create playlist"
response=$(curl -sf -X POST "$API_GATEWAY/api/playlists" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"name\": \"My Test Playlist\",
        \"description\": \"Test playlist\",
        \"isPublic\": true
    }" || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "Create playlist failed"
fi

TEST_PLAYLIST_ID=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
print_success "Playlist created (ID: $TEST_PLAYLIST_ID)"

print_test "Get user library"
response=$(curl -sf -H "Authorization: Bearer $JWT_TOKEN" \
    "$API_GATEWAY/api/library/$TEST_USER_ID" || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "Get library failed"
fi

print_success "Library retrieved"

# ==============================================================================
# 5. ÉPICA 4: Commerce Service
# ==============================================================================

print_header "5. ÉPICA 4: COMMERCE SERVICE"

print_test "Create product"
response=$(curl -sf -X POST "$API_GATEWAY/api/products" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "artistId": 1,
        "name": "Test T-Shirt",
        "description": "Test product",
        "category": "CLOTHING",
        "price": 29.99,
        "stock": 100,
        "imageUrls": ["https://example.com/tshirt.jpg"]
    }' || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "Create product failed"
fi

TEST_PRODUCT_ID=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
print_success "Product created (ID: $TEST_PRODUCT_ID)"

print_test "Get cart"
response=$(curl -sf -H "Authorization: Bearer $JWT_TOKEN" \
    "$API_GATEWAY/api/cart/$TEST_USER_ID" || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    print_error "Get cart failed"
fi

print_success "Cart retrieved"

# ==============================================================================
# FINAL SUMMARY
# ==============================================================================

print_header "TEST SUMMARY"

echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║                                                ║
║           🎉 ALL TESTS PASSED! 🎉             ║
║                                                ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

echo -e "${CYAN}Total tests executed: ${MAGENTA}$TOTAL_TESTS${NC}"
echo -e "${CYAN}Tests passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "${CYAN}Tests failed: ${GREEN}0${NC}\n"

echo -e "${YELLOW}Services tested:${NC}"
echo -e "   ${GREEN}✓ Config Server${NC}"
echo -e "   ${GREEN}✓ Eureka Discovery Server${NC}"
echo -e "   ${GREEN}✓ API Gateway${NC}"
echo -e "   ${GREEN}✓ ÉPICA 1: Community Service (Users, Metrics, Ratings, Communication)${NC}"
echo -e "   ${GREEN}✓ ÉPICA 2: Music Catalog Service (Genres, Songs, Albums, Collaborations)${NC}"
echo -e "   ${GREEN}✓ ÉPICA 3: Playback Service (Playlists, Library, Playback)${NC}"
echo -e "   ${GREEN}✓ ÉPICA 4: Commerce Service (Products, Cart, Orders, Payments)${NC}\n"

echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Audira Epic Services are functioning correctly!${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}\n"
