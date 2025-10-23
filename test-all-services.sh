#!/bin/bash

################################################################################
# AUDIRA MICROSERVICES - MEGA TEST SCRIPT
# Este script prueba TODOS los endpoints de TODOS los servicios
# Se detiene al primer error que encuentre
################################################################################

set -e  # Detener al primer error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración
API_GATEWAY="http://localhost:8080"
CONFIG_SERVER="http://localhost:8888"
EUREKA_SERVER="http://localhost:8761"

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0

# Variable para almacenar el JWT token
JWT_TOKEN=""
TEST_USER_ID=""
TEST_GENRE_ID=""
TEST_ALBUM_ID=""
TEST_SONG_ID=""
TEST_ARTIST_ID=""
TEST_COLLABORATION_ID=""
TEST_PLAYLIST_ID=""
TEST_LIBRARY_ITEM_ID=""
TEST_COLLECTION_ID=""
TEST_RATING_ID=""
TEST_COMMENT_ID=""
TEST_CART_ITEM_ID=""
TEST_PRODUCT_ID=""
TEST_FAQ_ID=""
TEST_NOTIFICATION_ID=""
TEST_ORDER_ID=""
TEST_PAYMENT_ID=""

################################################################################
# FUNCIONES AUXILIARES
################################################################################

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${YELLOW}[TEST $TOTAL_TESTS]${NC} $1"
}

print_success() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}✓ PASSED${NC} - $1\n"
}

print_error() {
    echo -e "${RED}✗ FAILED${NC} - $1"
    echo -e "${RED}ERROR: La prueba falló. Deteniendo el script.${NC}"
    exit 1
}

check_response() {
    local response=$1
    local expected_code=$2
    local test_name=$3

    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')

    if [ "$http_code" != "$expected_code" ]; then
        print_error "$test_name - Expected HTTP $expected_code but got $http_code. Body: $body"
    fi

    print_success "$test_name (HTTP $http_code)"
    echo "$body"
}

wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1

    echo -e "${BLUE}Esperando a que $service_name esté disponible...${NC}"

    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $service_name está disponible${NC}\n"
            return 0
        fi
        echo "Intento $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done

    print_error "$service_name no está disponible después de $max_attempts intentos"
}

################################################################################
# INICIO DE PRUEBAS
################################################################################

echo -e "${MAGENTA}"
cat << "EOF"
   ___   __  ______  _____  ___  ___
  / _ | / / / / __ \/  _/ |/ / |/ _ |
 / __ |/ /_/ / /_/ // // /|  /| / __ |
/_/ |_|\____/\____/___/_/ |_/ |_/_/ |_|

MEGA TEST SUITE - TESTING ALL SERVICES
EOF
echo -e "${NC}\n"

################################################################################
# 1. VERIFICAR INFRAESTRUCTURA
################################################################################

print_header "1. VERIFICANDO SERVICIOS DE INFRAESTRUCTURA"

# Config Server
print_test "Config Server - Health Check"
wait_for_service "$CONFIG_SERVER/actuator/health" "Config Server"

# Eureka Server
print_test "Eureka Server - Health Check"
wait_for_service "$EUREKA_SERVER/actuator/health" "Eureka Discovery Server"

# API Gateway
print_test "API Gateway - Health Check"
wait_for_service "$API_GATEWAY/actuator/health" "API Gateway"

echo -e "${GREEN}✓ Todos los servicios de infraestructura están disponibles${NC}\n"

# Esperar a que los servicios se registren en Eureka
echo -e "${BLUE}Esperando 10 segundos para que los servicios se registren en Eureka...${NC}"
sleep 10

################################################################################
# 2. USER SERVICE - AUTENTICACIÓN Y USUARIOS
################################################################################

print_header "2. USER SERVICE - Autenticación y Gestión de Usuarios"

# Registrar un nuevo usuario
print_test "Crear nuevo usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/auth/register" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "email": "testuser@audira.com",
        "password": "Password123!",
        "fullName": "Test User"
    }')
USER_DATA=$(check_response "$RESPONSE" "200" "Registro de usuario")
TEST_USER_ID=$(echo "$USER_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Usuario creado con ID: $TEST_USER_ID"

# Login
print_test "Login de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "password": "Password123!"
    }')
LOGIN_DATA=$(check_response "$RESPONSE" "200" "Login de usuario")
JWT_TOKEN=$(echo "$LOGIN_DATA" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo "JWT Token obtenido: ${JWT_TOKEN:0:50}..."

# Verificar que tenemos el token
if [ -z "$JWT_TOKEN" ]; then
    print_error "No se pudo obtener el JWT token"
fi

# Obtener perfil de usuario
print_test "Obtener perfil de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/users/profile" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener perfil de usuario"

# Actualizar perfil
print_test "Actualizar perfil de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/users/profile" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "fullName": "Test User Updated",
        "bio": "This is my updated bio"
    }')
check_response "$RESPONSE" "200" "Actualizar perfil de usuario"

# Obtener usuario por ID
print_test "Obtener usuario por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener usuario por ID"

# Listar todos los usuarios
print_test "Listar todos los usuarios"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/users" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Listar todos los usuarios"

################################################################################
# 3. CATALOG SERVICE - Géneros, Álbumes, Canciones, Artistas
################################################################################

print_header "3. CATALOG SERVICE - Catálogo de Música"

# === GENRES ===
print_test "Crear género"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/genres" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Rock",
        "description": "Rock music genre",
        "imageUrl": "https://example.com/rock.jpg"
    }')
GENRE_DATA=$(check_response "$RESPONSE" "201" "Crear género")
TEST_GENRE_ID=$(echo "$GENRE_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Género creado con ID: $TEST_GENRE_ID"

print_test "Obtener todos los géneros"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/genres" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Listar géneros"

print_test "Obtener género por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/genres/$TEST_GENRE_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener género por ID"

print_test "Actualizar género"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/genres/$TEST_GENRE_ID" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Rock Updated",
        "description": "Updated description"
    }')
check_response "$RESPONSE" "200" "Actualizar género"

# === ALBUMS ===
print_test "Crear álbum"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/albums" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Test Album\",
        \"artistId\": 1,
        \"genreId\": $TEST_GENRE_ID,
        \"releaseDate\": \"2024-01-01T00:00:00\",
        \"coverImageUrl\": \"https://example.com/album.jpg\",
        \"price\": 9.99,
        \"description\": \"Test album description\"
    }")
ALBUM_DATA=$(check_response "$RESPONSE" "201" "Crear álbum")
TEST_ALBUM_ID=$(echo "$ALBUM_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Álbum creado con ID: $TEST_ALBUM_ID"

print_test "Obtener todos los álbumes"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/albums" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Listar álbumes"

print_test "Obtener álbum por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/albums/$TEST_ALBUM_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener álbum por ID"

print_test "Obtener álbumes recientes"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/albums/recent" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener álbumes recientes"

# === SONGS ===
print_test "Crear canción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/songs" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Test Song\",
        \"artistId\": 1,
        \"albumId\": $TEST_ALBUM_ID,
        \"genreId\": $TEST_GENRE_ID,
        \"duration\": 240,
        \"audioUrl\": \"https://example.com/song.mp3\",
        \"coverImageUrl\": \"https://example.com/cover.jpg\",
        \"price\": 1.99,
        \"lyrics\": \"Test lyrics\"
    }")
SONG_DATA=$(check_response "$RESPONSE" "201" "Crear canción")
TEST_SONG_ID=$(echo "$SONG_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Canción creada con ID: $TEST_SONG_ID"

print_test "Obtener todas las canciones"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/songs" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Listar canciones"

print_test "Obtener canción por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/songs/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener canción por ID"

print_test "Buscar canciones"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/songs/search?q=Test" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Buscar canciones"

print_test "Obtener canciones populares"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/songs/popular?limit=10" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener canciones populares"

# === COLLABORATIONS ===
print_test "Crear colaboración"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/collaborations" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"songId\": $TEST_SONG_ID,
        \"collaboratorIds\": [1, 2],
        \"collaboratorNames\": [\"Artist 1\", \"Artist 2\"],
        \"roles\": [\"Vocals\", \"Guitar\"]
    }")
COLLAB_DATA=$(check_response "$RESPONSE" "201" "Crear colaboración")
TEST_COLLABORATION_ID=$(echo "$COLLAB_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Colaboración creada con ID: $TEST_COLLABORATION_ID"

print_test "Obtener colaboraciones por canción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/collaborations/song/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener colaboraciones por canción"

# === DISCOVERY ===
print_test "Obtener contenido de descubrimiento"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/discovery/featured" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener contenido destacado"

################################################################################
# 4. PLAYER SERVICE - Reproducción
################################################################################

print_header "4. PLAYER SERVICE - Reproducción de Música"

# === PLAYBACK ===
print_test "Iniciar reproducción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/playback/start" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"songId\": $TEST_SONG_ID,
        \"duration\": 240
    }")
PLAYBACK_DATA=$(check_response "$RESPONSE" "200" "Iniciar reproducción")
PLAYBACK_SESSION_ID=$(echo "$PLAYBACK_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Sesión de reproducción creada con ID: $PLAYBACK_SESSION_ID"

print_test "Obtener estado de reproducción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/playback/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener estado de reproducción"

print_test "Pausar reproducción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/playback/$PLAYBACK_SESSION_ID/pause" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Pausar reproducción"

print_test "Reanudar reproducción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/playback/$PLAYBACK_SESSION_ID/resume" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Reanudar reproducción"

print_test "Detener reproducción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/playback/$PLAYBACK_SESSION_ID/stop" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Detener reproducción"

# === QUEUE ===
print_test "Crear cola de reproducción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/queue" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"songIds\": [$TEST_SONG_ID]
    }")
QUEUE_DATA=$(check_response "$RESPONSE" "200" "Crear cola de reproducción")
QUEUE_ID=$(echo "$QUEUE_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Cola creada con ID: $QUEUE_ID"

print_test "Obtener cola de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/queue/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener cola de usuario"

print_test "Agregar canción a la cola"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/queue/$QUEUE_ID/add?songId=$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Agregar canción a la cola"

print_test "Limpiar cola"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/queue/$QUEUE_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Limpiar cola"

# === HISTORY ===
print_test "Obtener historial de reproducción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/history/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener historial de reproducción"

print_test "Obtener canciones reproducidas recientemente"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/history/$TEST_USER_ID/recent?limit=10" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener canciones recientes"

################################################################################
# 5. LIBRARY SERVICE - Biblioteca del Usuario
################################################################################

print_header "5. LIBRARY SERVICE - Biblioteca Personal"

# === LIBRARY ITEMS ===
print_test "Agregar canción a biblioteca"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/library" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"itemType\": \"SONG\",
        \"itemId\": $TEST_SONG_ID
    }")
LIBRARY_DATA=$(check_response "$RESPONSE" "200" "Agregar a biblioteca")
TEST_LIBRARY_ITEM_ID=$(echo "$LIBRARY_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Item de biblioteca creado con ID: $TEST_LIBRARY_ITEM_ID"

print_test "Obtener biblioteca del usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/library/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener biblioteca"

print_test "Obtener biblioteca por tipo"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/library/$TEST_USER_ID/type/SONG" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener biblioteca por tipo"

print_test "Marcar como favorito"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/library/$TEST_USER_ID/favorite?itemType=SONG&itemId=$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Marcar como favorito"

print_test "Obtener favoritos"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/library/$TEST_USER_ID/favorites" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener favoritos"

# === COLLECTIONS ===
print_test "Crear colección"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/library/collections" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"name\": \"My Collection\",
        \"description\": \"Test collection\"
    }")
COLLECTION_DATA=$(check_response "$RESPONSE" "200" "Crear colección")
TEST_COLLECTION_ID=$(echo "$COLLECTION_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Colección creada con ID: $TEST_COLLECTION_ID"

print_test "Obtener colección por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/library/collections/$TEST_COLLECTION_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener colección por ID"

print_test "Obtener colecciones de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/library/collections/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener colecciones de usuario"

print_test "Agregar item a colección"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/library/collections/$TEST_COLLECTION_ID/items?itemId=$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Agregar item a colección"

print_test "Actualizar colección"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/library/collections/$TEST_COLLECTION_ID" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Updated Collection\",
        \"description\": \"Updated description\"
    }")
check_response "$RESPONSE" "200" "Actualizar colección"

################################################################################
# 6. RATINGS SERVICE - Calificaciones y Comentarios
################################################################################

print_header "6. RATINGS SERVICE - Calificaciones y Comentarios"

# === RATINGS ===
print_test "Crear/actualizar calificación"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/ratings" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -d "userId=$TEST_USER_ID&entityType=SONG&entityId=$TEST_SONG_ID&rating=5")
RATING_DATA=$(check_response "$RESPONSE" "200" "Crear calificación")
TEST_RATING_ID=$(echo "$RATING_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Calificación creada con ID: $TEST_RATING_ID"

print_test "Obtener calificación de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/ratings/user/$TEST_USER_ID/entity/SONG/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener calificación de usuario"

print_test "Obtener calificaciones de entidad"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/ratings/entity/SONG/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener calificaciones de entidad"

print_test "Obtener promedio y conteo de calificaciones"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/ratings/entity/SONG/$TEST_SONG_ID/average" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener estadísticas de calificaciones"

print_test "Obtener todas las calificaciones de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/ratings/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener calificaciones de usuario"

# === COMMENTS ===
print_test "Crear comentario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/comments" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"entityType\": \"SONG\",
        \"entityId\": $TEST_SONG_ID,
        \"content\": \"This is a test comment\"
    }")
COMMENT_DATA=$(check_response "$RESPONSE" "200" "Crear comentario")
TEST_COMMENT_ID=$(echo "$COMMENT_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Comentario creado con ID: $TEST_COMMENT_ID"

print_test "Obtener comentario por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/comments/$TEST_COMMENT_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener comentario por ID"

print_test "Obtener comentarios de entidad"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/comments/entity/SONG/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener comentarios de entidad"

print_test "Obtener comentarios de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/comments/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener comentarios de usuario"

print_test "Dar like a comentario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/comments/$TEST_COMMENT_ID/like" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Dar like a comentario"

print_test "Actualizar comentario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/comments/$TEST_COMMENT_ID" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -d "content=Updated comment content")
check_response "$RESPONSE" "200" "Actualizar comentario"

################################################################################
# 7. CART SERVICE - Carrito de Compras
################################################################################

print_header "7. CART SERVICE - Carrito de Compras"

print_test "Agregar item al carrito"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/cart/$TEST_USER_ID/items" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -d "itemType=SONG&itemId=$TEST_SONG_ID&quantity=1&price=1.99")
CART_DATA=$(check_response "$RESPONSE" "200" "Agregar item al carrito")

print_test "Obtener carrito"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/cart/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
CART_FULL_DATA=$(check_response "$RESPONSE" "200" "Obtener carrito")
CART_ITEM_ID=$(echo "$CART_FULL_DATA" | grep -o '"id":[0-9]*' | tail -1 | cut -d':' -f2)
echo "Item del carrito con ID: $CART_ITEM_ID"

print_test "Obtener conteo de items del carrito"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/cart/$TEST_USER_ID/count" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener conteo de items"

print_test "Obtener total del carrito"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/cart/$TEST_USER_ID/total" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener total del carrito"

print_test "Actualizar cantidad de item"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/cart/$TEST_USER_ID/items/$CART_ITEM_ID" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -d "quantity=2")
check_response "$RESPONSE" "200" "Actualizar cantidad de item"

################################################################################
# 8. PLAYLIST SERVICE - Listas de Reproducción
################################################################################

print_header "8. PLAYLIST SERVICE - Listas de Reproducción"

print_test "Crear playlist"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/playlists" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"name\": \"My Test Playlist\",
        \"description\": \"Test playlist description\",
        \"isPublic\": true
    }")
PLAYLIST_DATA=$(check_response "$RESPONSE" "201" "Crear playlist")
TEST_PLAYLIST_ID=$(echo "$PLAYLIST_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Playlist creada con ID: $TEST_PLAYLIST_ID"

print_test "Obtener playlist por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/playlists/$TEST_PLAYLIST_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener playlist por ID"

print_test "Obtener playlists de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/playlists/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener playlists de usuario"

print_test "Obtener playlists públicas"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/playlists/public" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener playlists públicas"

print_test "Agregar canción a playlist"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/playlists/$TEST_PLAYLIST_ID/songs/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Agregar canción a playlist"

print_test "Actualizar playlist"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/playlists/$TEST_PLAYLIST_ID" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Updated Playlist\",
        \"description\": \"Updated description\",
        \"isPublic\": false
    }")
check_response "$RESPONSE" "200" "Actualizar playlist"

################################################################################
# 9. STORE SERVICE - Tienda de Productos
################################################################################

print_header "9. STORE SERVICE - Tienda de Productos"

print_test "Crear producto"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/products" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"artistId\": 1,
        \"name\": \"Test T-Shirt\",
        \"description\": \"Test product description\",
        \"category\": \"CLOTHING\",
        \"price\": 29.99,
        \"stock\": 100,
        \"imageUrls\": [\"https://example.com/tshirt.jpg\"]
    }")
PRODUCT_DATA=$(check_response "$RESPONSE" "201" "Crear producto")
TEST_PRODUCT_ID=$(echo "$PRODUCT_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Producto creado con ID: $TEST_PRODUCT_ID"

print_test "Obtener producto por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/products/$TEST_PRODUCT_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener producto por ID"

print_test "Obtener todos los productos"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/products" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener todos los productos"

print_test "Obtener categorías de productos"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/products/categories" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener categorías"

print_test "Buscar productos"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/products?search=Test" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Buscar productos"

print_test "Actualizar stock de producto"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PATCH "$API_GATEWAY/api/products/$TEST_PRODUCT_ID/stock?stock=95" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Actualizar stock"

print_test "Actualizar producto"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/products/$TEST_PRODUCT_ID" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Updated T-Shirt\",
        \"description\": \"Updated description\",
        \"price\": 24.99,
        \"stock\": 95
    }")
check_response "$RESPONSE" "200" "Actualizar producto"

################################################################################
# 10. COMMUNICATION SERVICE - Comunicación
################################################################################

print_header "10. COMMUNICATION SERVICE - Comunicación"

# === FAQ ===
print_test "Crear FAQ"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/faq" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"category\": \"GENERAL\",
        \"question\": \"How do I create an account?\",
        \"answer\": \"Click on the register button and fill in your details.\",
        \"language\": \"EN\",
        \"order\": 1
    }")
FAQ_DATA=$(check_response "$RESPONSE" "200" "Crear FAQ")
TEST_FAQ_ID=$(echo "$FAQ_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "FAQ creada con ID: $TEST_FAQ_ID"

print_test "Obtener FAQ por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/faq/$TEST_FAQ_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener FAQ por ID"

print_test "Obtener todas las FAQs"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/faq" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener todas las FAQs"

print_test "Obtener FAQs por categoría"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/faq/category/GENERAL" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener FAQs por categoría"

print_test "Actualizar FAQ"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/faq/$TEST_FAQ_ID" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"question\": \"How do I create an account? (Updated)\",
        \"answer\": \"Updated answer\"
    }")
check_response "$RESPONSE" "200" "Actualizar FAQ"

# === CONTACT ===
print_test "Crear mensaje de contacto"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/contact" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"name\": \"Test User\",
        \"email\": \"testuser@audira.com\",
        \"subject\": \"Test Subject\",
        \"message\": \"This is a test message\",
        \"messageType\": \"GENERAL_INQUIRY\"
    }")
CONTACT_DATA=$(check_response "$RESPONSE" "200" "Crear mensaje de contacto")
CONTACT_MESSAGE_ID=$(echo "$CONTACT_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Mensaje de contacto creado con ID: $CONTACT_MESSAGE_ID"

print_test "Obtener mensaje de contacto por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/contact/$CONTACT_MESSAGE_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener mensaje por ID"

print_test "Obtener mensajes por usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/contact/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener mensajes por usuario"

print_test "Obtener mensajes pendientes"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/contact/pending" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener mensajes pendientes"

# === NOTIFICATIONS ===
print_test "Crear notificación"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/notifications" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"type\": \"INFO\",
        \"title\": \"Test Notification\",
        \"message\": \"This is a test notification\",
        \"priority\": \"MEDIUM\"
    }")
NOTIF_DATA=$(check_response "$RESPONSE" "200" "Crear notificación")
TEST_NOTIFICATION_ID=$(echo "$NOTIF_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Notificación creada con ID: $TEST_NOTIFICATION_ID"

print_test "Obtener notificación por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/notifications/$TEST_NOTIFICATION_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener notificación por ID"

print_test "Obtener notificaciones de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/notifications/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener notificaciones de usuario"

print_test "Obtener notificaciones no leídas"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/notifications/user/$TEST_USER_ID/unread" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener notificaciones no leídas"

print_test "Marcar notificación como leída"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/notifications/$TEST_NOTIFICATION_ID/read" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Marcar como leída"

################################################################################
# 11. ORDER SERVICE - Órdenes
################################################################################

print_header "11. ORDER SERVICE - Gestión de Órdenes"

print_test "Crear orden"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/orders" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"userId\": $TEST_USER_ID,
        \"items\": [
            {
                \"itemType\": \"SONG\",
                \"itemId\": $TEST_SONG_ID,
                \"quantity\": 1,
                \"price\": 1.99
            }
        ],
        \"shippingAddress\": \"123 Test Street, Test City, TC 12345\"
    }")
ORDER_DATA=$(check_response "$RESPONSE" "201" "Crear orden")
TEST_ORDER_ID=$(echo "$ORDER_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
ORDER_NUMBER=$(echo "$ORDER_DATA" | grep -o '"orderNumber":"[^"]*"' | cut -d'"' -f4)
echo "Orden creada con ID: $TEST_ORDER_ID, Número: $ORDER_NUMBER"

print_test "Obtener orden por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/orders/$TEST_ORDER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener orden por ID"

print_test "Obtener orden por número"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/orders/order-number/$ORDER_NUMBER" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener orden por número"

print_test "Obtener todas las órdenes"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/orders" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener todas las órdenes"

print_test "Obtener órdenes de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/orders/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener órdenes de usuario"

print_test "Obtener órdenes por estado"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/orders/status/PENDING" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener órdenes por estado"

print_test "Actualizar estado de orden"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API_GATEWAY/api/orders/$TEST_ORDER_ID/status" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"status\": \"PROCESSING\"
    }")
check_response "$RESPONSE" "200" "Actualizar estado de orden"

################################################################################
# 12. PAYMENT SERVICE - Pagos
################################################################################

print_header "12. PAYMENT SERVICE - Procesamiento de Pagos"

print_test "Crear pago"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/payments" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -d "orderId=$TEST_ORDER_ID&userId=$TEST_USER_ID&amount=1.99&paymentMethod=CREDIT_CARD")
PAYMENT_DATA=$(check_response "$RESPONSE" "200" "Crear pago")
TEST_PAYMENT_ID=$(echo "$PAYMENT_DATA" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
TRANSACTION_ID=$(echo "$PAYMENT_DATA" | grep -o '"transactionId":"[^"]*"' | cut -d'"' -f4)
echo "Pago creado con ID: $TEST_PAYMENT_ID, Transaction ID: $TRANSACTION_ID"

print_test "Obtener pago por ID"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/payments/$TEST_PAYMENT_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener pago por ID"

print_test "Obtener pago por orden"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/payments/order/$TEST_ORDER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener pago por orden"

print_test "Obtener pagos de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/payments/user/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener pagos de usuario"

print_test "Procesar pago"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/payments/$TEST_PAYMENT_ID/process" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -d "transactionId=TXN-TEST-12345")
check_response "$RESPONSE" "200" "Procesar pago"

print_test "Completar pago"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/payments/$TEST_PAYMENT_ID/complete" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Completar pago"

################################################################################
# 13. METRICS SERVICE - Métricas
################################################################################

print_header "13. METRICS SERVICE - Métricas y Estadísticas"

# === USER METRICS ===
print_test "Obtener métricas de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/metrics/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener métricas de usuario"

print_test "Incrementar reproducciones de usuario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/users/$TEST_USER_ID/plays" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar reproducciones"

print_test "Agregar tiempo de escucha"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/users/$TEST_USER_ID/listening-time?seconds=120" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Agregar tiempo de escucha"

print_test "Incrementar seguidores"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/users/$TEST_USER_ID/followers/increment" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar seguidores"

print_test "Incrementar siguiendo"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/users/$TEST_USER_ID/following/increment" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar siguiendo"

print_test "Incrementar compras"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/users/$TEST_USER_ID/purchases" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar compras"

# === ARTIST METRICS ===
print_test "Obtener métricas de artista"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/metrics/artists/1" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener métricas de artista"

print_test "Incrementar reproducciones de artista"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/artists/1/plays" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar reproducciones de artista"

print_test "Incrementar oyentes de artista"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/artists/1/listeners" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar oyentes"

print_test "Incrementar seguidores de artista"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/artists/1/followers/increment" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar seguidores de artista"

print_test "Agregar venta de artista"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/artists/1/sales?amount=9.99" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Agregar venta de artista"

# === SONG METRICS ===
print_test "Obtener métricas de canción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/metrics/songs/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener métricas de canción"

print_test "Incrementar reproducciones de canción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/songs/$TEST_SONG_ID/plays" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar reproducciones de canción"

print_test "Incrementar oyentes únicos"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/songs/$TEST_SONG_ID/listeners" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar oyentes únicos"

print_test "Incrementar likes de canción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/songs/$TEST_SONG_ID/likes" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar likes"

print_test "Incrementar compartidos"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/songs/$TEST_SONG_ID/shares" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar compartidos"

print_test "Incrementar descargas"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/metrics/songs/$TEST_SONG_ID/downloads" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Incrementar descargas"

# === GLOBAL METRICS ===
print_test "Obtener métricas globales"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_GATEWAY/api/metrics/global" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Obtener métricas globales"

################################################################################
# 14. PRUEBAS DE LIMPIEZA (DELETES)
################################################################################

print_header "14. PRUEBAS DE ELIMINACIÓN - Limpieza de Datos de Prueba"

print_test "Eliminar comentario"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/comments/$TEST_COMMENT_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar comentario"

print_test "Eliminar calificación"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/ratings/$TEST_RATING_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar calificación"

print_test "Eliminar canción de playlist"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/playlists/$TEST_PLAYLIST_ID/songs/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Eliminar canción de playlist"

print_test "Eliminar playlist"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/playlists/$TEST_PLAYLIST_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar playlist"

print_test "Eliminar item de colección"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/library/collections/$TEST_COLLECTION_ID/items/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Eliminar item de colección"

print_test "Eliminar colección"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/library/collections/$TEST_COLLECTION_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar colección"

print_test "Eliminar de biblioteca"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/library?userId=$TEST_USER_ID&itemType=SONG&itemId=$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar de biblioteca"

print_test "Eliminar item del carrito"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/cart/$TEST_USER_ID/items/$CART_ITEM_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Eliminar item del carrito"

print_test "Limpiar carrito"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/cart/$TEST_USER_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Limpiar carrito"

print_test "Eliminar producto"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/products/$TEST_PRODUCT_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar producto"

print_test "Eliminar FAQ"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/faq/$TEST_FAQ_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar FAQ"

print_test "Eliminar notificación"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/notifications/$TEST_NOTIFICATION_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar notificación"

print_test "Cancelar orden"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_GATEWAY/api/orders/$TEST_ORDER_ID/cancel" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "200" "Cancelar orden"

print_test "Eliminar colaboración"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/collaborations/$TEST_COLLABORATION_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar colaboración"

print_test "Eliminar canción"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/songs/$TEST_SONG_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar canción"

print_test "Eliminar álbum"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/albums/$TEST_ALBUM_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar álbum"

print_test "Eliminar género"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_GATEWAY/api/genres/$TEST_GENRE_ID" \
    -H "Authorization: Bearer $JWT_TOKEN")
check_response "$RESPONSE" "204" "Eliminar género"

################################################################################
# RESUMEN FINAL
################################################################################

print_header "RESUMEN DE PRUEBAS"

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║          🎉 TODAS LAS PRUEBAS PASARON 🎉       ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Total de pruebas ejecutadas:${NC} ${MAGENTA}$TOTAL_TESTS${NC}"
echo -e "${CYAN}Pruebas exitosas:${NC} ${GREEN}$PASSED_TESTS${NC}"
echo -e "${CYAN}Pruebas fallidas:${NC} ${GREEN}0${NC}"
echo ""
echo -e "${YELLOW}Servicios probados:${NC}"
echo -e "  ${GREEN}✓${NC} Config Server"
echo -e "  ${GREEN}✓${NC} Eureka Discovery Server"
echo -e "  ${GREEN}✓${NC} API Gateway"
echo -e "  ${GREEN}✓${NC} User Service (Autenticación y Usuarios)"
echo -e "  ${GREEN}✓${NC} Catalog Service (Géneros, Álbumes, Canciones, Colaboraciones)"
echo -e "  ${GREEN}✓${NC} Player Service (Reproducción, Cola, Historial)"
echo -e "  ${GREEN}✓${NC} Library Service (Biblioteca y Colecciones)"
echo -e "  ${GREEN}✓${NC} Ratings Service (Calificaciones y Comentarios)"
echo -e "  ${GREEN}✓${NC} Cart Service (Carrito de Compras)"
echo -e "  ${GREEN}✓${NC} Playlist Service (Listas de Reproducción)"
echo -e "  ${GREEN}✓${NC} Store Service (Tienda de Productos)"
echo -e "  ${GREEN}✓${NC} Communication Service (FAQ, Contacto, Notificaciones)"
echo -e "  ${GREEN}✓${NC} Order Service (Gestión de Órdenes)"
echo -e "  ${GREEN}✓${NC} Payment Service (Procesamiento de Pagos)"
echo -e "  ${GREEN}✓${NC} Metrics Service (Métricas de Usuario, Artista, Canción, Global)"
echo ""
echo -e "${MAGENTA}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}El sistema Audira está funcionando perfectamente!${NC}"
echo -e "${MAGENTA}════════════════════════════════════════════════${NC}"
echo ""

exit 0
