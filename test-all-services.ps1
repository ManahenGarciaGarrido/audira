# ==============================================================================
# AUDIRA MICROSERVICES - MEGA TEST SCRIPT (PowerShell)
# Este script prueba TODOS los endpoints de TODOS los servicios
# Se detiene al primer error que encuentre
# ==============================================================================

$ErrorActionPreference = "Stop"

# Configuración
$API_GATEWAY = "http://localhost:8080"
$CONFIG_SERVER = "http://localhost:8888"
$EUREKA_SERVER = "http://localhost:8761"

# Contadores
$script:TOTAL_TESTS = 0
$script:PASSED_TESTS = 0

# Variables para almacenar datos
$script:JWT_TOKEN = ""
$script:TEST_USER_ID = ""
$script:TEST_GENRE_ID = ""
$script:TEST_ALBUM_ID = ""
$script:TEST_SONG_ID = ""
$script:TEST_COLLABORATION_ID = ""
$script:TEST_PLAYLIST_ID = ""
$script:TEST_COLLECTION_ID = ""
$script:TEST_RATING_ID = ""
$script:TEST_COMMENT_ID = ""
$script:CART_ITEM_ID = ""
$script:TEST_PRODUCT_ID = ""
$script:TEST_FAQ_ID = ""
$script:TEST_NOTIFICATION_ID = ""
$script:TEST_ORDER_ID = ""
$script:ORDER_NUMBER = ""
$script:TEST_PAYMENT_ID = ""
$script:TRANSACTION_ID = ""
$script:PLAYBACK_SESSION_ID = ""
$script:QUEUE_ID = ""
$script:CONTACT_MESSAGE_ID = ""

# ==============================================================================
# FUNCIONES AUXILIARES
# ==============================================================================

function Print-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Print-Test {
    param([string]$Message)
    $script:TOTAL_TESTS++
    Write-Host "[TEST $($script:TOTAL_TESTS)] $Message" -ForegroundColor Yellow
}

function Print-Success {
    param([string]$Message)
    $script:PASSED_TESTS++
    Write-Host "✓ PASSED - $Message`n" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ FAILED - $Message" -ForegroundColor Red
    Write-Host "ERROR: La prueba falló. Deteniendo el script." -ForegroundColor Red
    exit 1
}

function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers = @{},
        [object]$Body = $null,
        [string]$ContentType = "application/json"
    )

    try {
        $params = @{
            Method = $Method
            Uri = $Uri
            Headers = $Headers
            ContentType = $ContentType
            ErrorAction = "Stop"
        }

        if ($Body -ne $null) {
            if ($ContentType -eq "application/json") {
                $params.Body = ($Body | ConvertTo-Json -Depth 10)
            } else {
                $params.Body = $Body
            }
        }

        $response = Invoke-RestMethod @params
        return @{
            StatusCode = 200 # Asumimos 200 en éxito de Invoke-RestMethod
            Body = $response
        }
    }
    catch {
        $statusCode = 500
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }

        $errorBody = ""
        try {
            # Intenta leer el cuerpo del error
            $errorBody = $_.Exception.Response.Content.ReadAsStringAsync().Result
        } catch {
            try {
                 $errorBody = $_.ErrorDetails.Message
            } catch {
                $errorBody = $_.Exception.Message
            }
        }

        # Manejo especial para 404 y otros
        if ($statusCode -ne 200 -and $errorBody -like "*{*") {
             try {
                # Intenta deserializar el JSON de error
                $errorJson = $errorBody | ConvertFrom-Json
                $errorBody = "Error: $($errorJson.error), Path: $($errorJson.path), Status: $($errorJson.status), Message: $($errorJson.message)"
             } catch {
                # Si falla, usa el body tal cual
             }
        }

        return @{
            StatusCode = $statusCode
            Body = $errorBody
            Error = $true
        }
    }
}


function Check-Response {
    param(
        [object]$Response,
        [int]$ExpectedCode,
        [string]$TestName
    )

    if ($Response.Error) {
        Print-Error "$TestName - Expected HTTP $ExpectedCode but got $($Response.StatusCode). Body: $($Response.Body)"
    }

    if ($Response.StatusCode -ne $ExpectedCode) {
        Print-Error "$TestName - Expected HTTP $ExpectedCode but got $($Response.StatusCode). Body: $($Response.Body)"
    }

    Print-Success "$TestName (HTTP $($Response.StatusCode))"
    return $Response.Body
}

function Wait-ForService {
    param(
        [string]$Url,
        [string]$ServiceName,
        [int]$MaxAttempts = 30
    )

    Write-Host "Esperando a que $ServiceName esté disponible..." -ForegroundColor Blue

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            $null = Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
            Write-Host "✓ $ServiceName está disponible`n" -ForegroundColor Green
            return
        }
        catch {
            Write-Host "Intento $i/$MaxAttempts..."
            Start-Sleep -Seconds 2
        }
    }

    Print-Error "$ServiceName no está disponible después de $MaxAttempts intentos"
}

# ==============================================================================
# INICIO DE PRUEBAS
# ==============================================================================

Write-Host @"

    ___   __  ______  _____  ___  ___
  / _ | / / / / __ \/  _/ |/ / |/ _ |
 / __ |/ /_/ / /_/ // // /|  /| / __ |
/_/ |_|\____/\____/___/_/ |_/ |_/_/ |_|

MEGA TEST SUITE - TESTING ALL SERVICES

"@ -ForegroundColor Magenta

# ==============================================================================
# 1. VERIFICAR INFRAESTRUCTURA
# ==============================================================================

Print-Header "1. VERIFICANDO SERVICIOS DE INFRAESTRUCTURA"

Print-Test "Config Server - Health Check"
Wait-ForService "$CONFIG_SERVER/actuator/health" "Config Server"

Print-Test "Eureka Server - Health Check"
Wait-ForService "$EUREKA_SERVER/actuator/health" "Eureka Discovery Server"

Print-Test "API Gateway - Health Check"
Wait-ForService "$API_GATEWAY/actuator/health" "API Gateway"

Write-Host "✓ Todos los servicios de infraestructura están disponibles`n" -ForegroundColor Green
Write-Host "Esperando 10 segundos para que los servicios se registren en Eureka..." -ForegroundColor Blue
Start-Sleep -Seconds 10

# ==============================================================================
# 2. USER SERVICE - AUTENTICACIÓN Y USUARIOS
# ==============================================================================

Print-Header "2. USER SERVICE - Autenticación y Gestión de Usuarios"

Print-Test "Crear nuevo usuario"
# --- CORRECCIÓN AQUÍ ---
# Se envían firstName y lastName en lugar de fullName para coincidir con el DTO
$registerBody = @{
    username = "testuser"
    email = "testuser@audira.com"
    password = "Password123!"
    firstName = "Test"
    lastName = "User"
}
# La ruta pública sigue siendo /api/users/auth/register
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/users/auth/register" -Body $registerBody
$userData = Check-Response $response 200 "Registro de usuario"
$script:TEST_USER_ID = $userData.id
Write-Host "Usuario creado con ID: $($script:TEST_USER_ID)"

Print-Test "Login de usuario"
$loginBody = @{
    username = "testuser"
    password = "Password123!"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/users/auth/login" -Body $loginBody
$loginData = Check-Response $response 200 "Login de usuario"
$script:JWT_TOKEN = $loginData.token
Write-Host "JWT Token obtenido: $($script:JWT_TOKEN.Substring(0, [Math]::Min(50, $script:JWT_TOKEN.Length)))..."

if ([string]::IsNullOrEmpty($script:JWT_TOKEN)) {
    Print-Error "No se pudo obtener el JWT token"
}

$authHeaders = @{
    "Authorization" = "Bearer $($script:JWT_TOKEN)"
}

Print-Test "Obtener perfil de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/users/profile" -Headers $authHeaders
Check-Response $response 200 "Obtener perfil de usuario" | Out-Null

Print-Test "Actualizar perfil de usuario"
$updateProfileBody = @{
    fullName = "Test User Updated"
    bio = "This is my updated bio"
}
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/users/profile" -Headers $authHeaders -Body $updateProfileBody
Check-Response $response 200 "Actualizar perfil de usuario" | Out-Null

Print-Test "Obtener usuario por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/users/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener usuario por ID" | Out-Null

Print-Test "Listar todos los usuarios"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/users" -Headers $authHeaders
Check-Response $response 200 "Listar todos los usuarios" | Out-Null

# ==============================================================================
# 3. CATALOG SERVICE - Géneros, Álbumes, Canciones, Artistas
# ==============================================================================

Print-Header "3. CATALOG SERVICE - Catálogo de Música"

# === GENRES ===
Print-Test "Crear género"
$genreBody = @{
    name = "Rock"
    description = "Rock music genre"
    imageUrl = "https://example.com/rock.jpg"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/genres" -Headers $authHeaders -Body $genreBody
$genreData = Check-Response $response 201 "Crear género"
$script:TEST_GENRE_ID = $genreData.id
Write-Host "Género creado con ID: $($script:TEST_GENRE_ID)"

Print-Test "Obtener todos los géneros"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/genres" -Headers $authHeaders
Check-Response $response 200 "Listar géneros" | Out-Null

Print-Test "Obtener género por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/genres/$($script:TEST_GENRE_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener género por ID" | Out-Null

Print-Test "Actualizar género"
$updateGenreBody = @{
    name = "Rock Updated"
    description = "Updated description"
}
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/genres/$($script:TEST_GENRE_ID)" -Headers $authHeaders -Body $updateGenreBody
Check-Response $response 200 "Actualizar género" | Out-Null

# === ALBUMS ===
Print-Test "Crear álbum"
$albumBody = @{
    title = "Test Album"
    artistId = 1
    genreId = $script:TEST_GENRE_ID
    releaseDate = "2024-01-01T00:00:00"
    coverImageUrl = "https://example.com/album.jpg"
    price = 9.99
    description = "Test album description"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/albums" -Headers $authHeaders -Body $albumBody
$albumData = Check-Response $response 201 "Crear álbum"
$script:TEST_ALBUM_ID = $albumData.id
Write-Host "Álbum creado con ID: $($script:TEST_ALBUM_ID)"

Print-Test "Obtener todos los álbumes"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/albums" -Headers $authHeaders
Check-Response $response 200 "Listar álbumes" | Out-Null

Print-Test "Obtener álbum por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/albums/$($script:TEST_ALBUM_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener álbum por ID" | Out-Null

Print-Test "Obtener álbumes recientes"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/albums/recent" -Headers $authHeaders
Check-Response $response 200 "Obtener álbumes recientes" | Out-Null

# === SONGS ===
Print-Test "Crear canción"
$songBody = @{
    title = "Test Song"
    artistId = 1
    albumId = $script:TEST_ALBUM_ID
    genreId = $script:TEST_GENRE_ID
    duration = 240
    audioUrl = "https://example.com/song.mp3"
    coverImageUrl = "https://example.com/cover.jpg"
    price = 1.99
    lyrics = "Test lyrics"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/songs" -Headers $authHeaders -Body $songBody
$songData = Check-Response $response 201 "Crear canción"
$script:TEST_SONG_ID = $songData.id
Write-Host "Canción creada con ID: $($script:TEST_SONG_ID)"

Print-Test "Obtener todas las canciones"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/songs" -Headers $authHeaders
Check-Response $response 200 "Listar canciones" | Out-Null

Print-Test "Obtener canción por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/songs/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener canción por ID" | Out-Null

Print-Test "Buscar canciones"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/songs/search?q=Test" -Headers $authHeaders
Check-Response $response 200 "Buscar canciones" | Out-Null

Print-Test "Obtener canciones populares"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/songs/popular?limit=10" -Headers $authHeaders
Check-Response $response 200 "Obtener canciones populares" | Out-Null

# === COLLABORATIONS ===
Print-Test "Crear colaboración"
$collabBody = @{
    songId = $script:TEST_SONG_ID
    collaboratorIds = @(1, 2)
    collaboratorNames = @("Artist 1", "Artist 2")
    roles = @("Vocals", "Guitar")
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/collaborations" -Headers $authHeaders -Body $collabBody
$collabData = Check-Response $response 201 "Crear colaboración"
$script:TEST_COLLABORATION_ID = $collabData.id
Write-Host "Colaboración creada con ID: $($script:TEST_COLLABORATION_ID)"

Print-Test "Obtener colaboraciones por canción"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/collaborations/song/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener colaboraciones por canción" | Out-Null

# === DISCOVERY ===
Print-Test "Obtener contenido de descubrimiento"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/discovery/featured" -Headers $authHeaders
Check-Response $response 200 "Obtener contenido destacado" | Out-Null

# ==============================================================================
# 4. PLAYER SERVICE - Reproducción
# ==============================================================================

Print-Header "4. PLAYER SERVICE - Reproducción de Música"

Print-Test "Iniciar reproducción"
$playbackBody = @{
    userId = $script:TEST_USER_ID
    songId = $script:TEST_SONG_ID
    duration = 240
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/playback/start" -Headers $authHeaders -Body $playbackBody
$playbackData = Check-Response $response 200 "Iniciar reproducción"
$script:PLAYBACK_SESSION_ID = $playbackData.id
Write-Host "Sesión de reproducción creada con ID: $($script:PLAYBACK_SESSION_ID)"

Print-Test "Obtener estado de reproducción"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/playback/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener estado de reproducción" | Out-Null

Print-Test "Pausar reproducción"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/playback/$($script:PLAYBACK_SESSION_ID)/pause" -Headers $authHeaders
Check-Response $response 200 "Pausar reproducción" | Out-Null

Print-Test "Reanudar reproducción"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/playback/$($script:PLAYBACK_SESSION_ID)/resume" -Headers $authHeaders
Check-Response $response 200 "Reanudar reproducción" | Out-Null

Print-Test "Detener reproducción"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/playback/$($script:PLAYBACK_SESSION_ID)/stop" -Headers $authHeaders
Check-Response $response 200 "Detener reproducción" | Out-Null

# === QUEUE ===
Print-Test "Crear cola de reproducción"
$queueBody = @{
    userId = $script:TEST_USER_ID
    songIds = @($script:TEST_SONG_ID)
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/queue" -Headers $authHeaders -Body $queueBody
$queueData = Check-Response $response 200 "Crear cola de reproducción"
$script:QUEUE_ID = $queueData.id
Write-Host "Cola creada con ID: $($script:QUEUE_ID)"

Print-Test "Obtener cola de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/queue/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener cola de usuario" | Out-Null

Print-Test "Agregar canción a la cola"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/queue/$($script:QUEUE_ID)/add?songId=$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Agregar canción a la cola" | Out-Null

Print-Test "Limpiar cola"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/queue/$($script:QUEUE_ID)" -Headers $authHeaders
Check-Response $response 204 "Limpiar cola" | Out-Null

# === HISTORY ===
Print-Test "Obtener historial de reproducción"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/history/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener historial de reproducción" | Out-Null

Print-Test "Obtener canciones reproducidas recientemente"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/history/$($script:TEST_USER_ID)/recent?limit=10" -Headers $authHeaders
Check-Response $response 200 "Obtener canciones recientes" | Out-Null

# ==============================================================================
# 5. LIBRARY SERVICE - Biblioteca del Usuario
# ==============================================================================

Print-Header "5. LIBRARY SERVICE - Biblioteca Personal"

Print-Test "Agregar canción a biblioteca"
$libraryBody = @{
    userId = $script:TEST_USER_ID
    itemType = "SONG"
    itemId = $script:TEST_SONG_ID
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/library" -Headers $authHeaders -Body $libraryBody
Check-Response $response 200 "Agregar a biblioteca" | Out-Null

Print-Test "Obtener biblioteca del usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/library/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener biblioteca" | Out-Null

Print-Test "Obtener biblioteca por tipo"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/library/$($script:TEST_USER_ID)/type/SONG" -Headers $authHeaders
Check-Response $response 200 "Obtener biblioteca por tipo" | Out-Null

Print-Test "Marcar como favorito"
# --- CORRECCIÓN AQUÍ ---
# Faltaba escapar los ampersands
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/library/$($script:TEST_USER_ID)/favorite?itemType=SONG`&itemId=$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Marcar como favorito" | Out-Null

Print-Test "Obtener favoritos"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/library/$($script:TEST_USER_ID)/favorites" -Headers $authHeaders
Check-Response $response 200 "Obtener favoritos" | Out-Null

# === COLLECTIONS ===
Print-Test "Crear colección"
$collectionBody = @{
    userId = $script:TEST_USER_ID
    name = "My Collection"
    description = "Test collection"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/library/collections" -Headers $authHeaders -Body $collectionBody
$collectionData = Check-Response $response 200 "Crear colección"
$script:TEST_COLLECTION_ID = $collectionData.id
Write-Host "Colección creada con ID: $($script:TEST_COLLECTION_ID)"

Print-Test "Obtener colección por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/library/collections/$($script:TEST_COLLECTION_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener colección por ID" | Out-Null

Print-Test "Obtener colecciones de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/library/collections/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener colecciones de usuario" | Out-Null

Print-Test "Agregar item a colección"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/library/collections/$($script:TEST_COLLECTION_ID)/items?itemId=$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Agregar item a colección" | Out-Null

Print-Test "Actualizar colección"
$updateCollectionBody = @{
    name = "Updated Collection"
    description = "Updated description"
}
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/library/collections/$($script:TEST_COLLECTION_ID)" -Headers $authHeaders -Body $updateCollectionBody
Check-Response $response 200 "Actualizar colección" | Out-Null

# ==============================================================================
# 6. RATINGS SERVICE - Calificaciones y Comentarios
# ==============================================================================

Print-Header "6. RATINGS SERVICE - Calificaciones y Comentarios"

Print-Test "Crear/actualizar calificación"
# --- CORRECCIÓN AQUÍ ---
# Faltaba escapar los ampersands
$ratingParams = "userId=$($script:TEST_USER_ID)`&entityType=SONG`&entityId=$($script:TEST_SONG_ID)`&rating=5"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/ratings?$ratingParams" -Headers $authHeaders -ContentType "application/x-www-form-urlencoded"
$ratingData = Check-Response $response 200 "Crear calificación"
$script:TEST_RATING_ID = $ratingData.id
Write-Host "Calificación creada con ID: $($script:TEST_RATING_ID)"

Print-Test "Obtener calificación de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/ratings/user/$($script:TEST_USER_ID)/entity/SONG/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener calificación de usuario" | Out-Null

Print-Test "Obtener calificaciones de entidad"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/ratings/entity/SONG/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener calificaciones de entidad" | Out-Null

Print-Test "Obtener promedio y conteo de calificaciones"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/ratings/entity/SONG/$($script:TEST_SONG_ID)/average" -Headers $authHeaders
Check-Response $response 200 "Obtener estadísticas de calificaciones" | Out-Null

Print-Test "Obtener todas las calificaciones de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/ratings/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener calificaciones de usuario" | Out-Null

# === COMMENTS ===
Print-Test "Crear comentario"
$commentBody = @{
    userId = $script:TEST_USER_ID
    entityType = "SONG"
    entityId = $script:TEST_SONG_ID
    content = "This is a test comment"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/comments" -Headers $authHeaders -Body $commentBody
$commentData = Check-Response $response 200 "Crear comentario"
$script:TEST_COMMENT_ID = $commentData.id
Write-Host "Comentario creado con ID: $($script:TEST_COMMENT_ID)"

Print-Test "Obtener comentario por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/comments/$($script:TEST_COMMENT_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener comentario por ID" | Out-Null

Print-Test "Obtener comentarios de entidad"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/comments/entity/SONG/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener comentarios de entidad" | Out-Null

Print-Test "Obtener comentarios de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/comments/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener comentarios de usuario" | Out-Null

Print-Test "Dar like a comentario"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/comments/$($script:TEST_COMMENT_ID)/like" -Headers $authHeaders
Check-Response $response 200 "Dar like a comentario" | Out-Null

Print-Test "Actualizar comentario"
$updateCommentParams = "content=Updated comment content"
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/comments/$($script:TEST_COMMENT_ID)?$updateCommentParams" -Headers $authHeaders -ContentType "application/x-www-form-urlencoded"
Check-Response $response 200 "Actualizar comentario" | Out-Null

# ==============================================================================
# 7. CART SERVICE - Carrito de Compras
# ==============================================================================

Print-Header "7. CART SERVICE - Carrito de Compras"

Print-Test "Agregar item al carrito"
# --- CORRECCIÓN AQUÍ ---
# Faltaba escapar los ampersands
$cartParams = "itemType=SONG`&itemId=$($script:TEST_SONG_ID)`&quantity=1`&price=1.99"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/cart/$($script:TEST_USER_ID)/items?$cartParams" -Headers $authHeaders -ContentType "application/x-www-form-urlencoded"
Check-Response $response 200 "Agregar item al carrito" | Out-Null

Print-Test "Obtener carrito"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/cart/$($script:TEST_USER_ID)" -Headers $authHeaders
$cartData = Check-Response $response 200 "Obtener carrito"
if ($cartData.items -and $cartData.items.Count -gt 0) {
    $script:CART_ITEM_ID = $cartData.items[0].id
    Write-Host "Item del carrito con ID: $($script:CART_ITEM_ID)"
}

Print-Test "Obtener conteo de items del carrito"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/cart/$($script:TEST_USER_ID)/count" -Headers $authHeaders
Check-Response $response 200 "Obtener conteo de items" | Out-Null

Print-Test "Obtener total del carrito"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/cart/$($script:TEST_USER_ID)/total" -Headers $authHeaders
Check-Response $response 200 "Obtener total del carrito" | Out-Null

if (![string]::IsNullOrEmpty($script:CART_ITEM_ID)) {
    Print-Test "Actualizar cantidad de item"
    $updateCartParams = "quantity=2"
    $response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/cart/$($script:TEST_USER_ID)/items/$($script:CART_ITEM_ID)?$updateCartParams" -Headers $authHeaders -ContentType "application/x-www-form-urlencoded"
    Check-Response $response 200 "Actualizar cantidad de item" | Out-Null
}

# ==============================================================================
# 8. PLAYLIST SERVICE - Listas de Reproducción
# ==============================================================================

Print-Header "8. PLAYLIST SERVICE - Listas de Reproducción"

Print-Test "Crear playlist"
$playlistBody = @{
    userId = $script:TEST_USER_ID
    name = "My Test Playlist"
    description = "Test playlist description"
    isPublic = $true
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/playlists" -Headers $authHeaders -Body $playlistBody
$playlistData = Check-Response $response 201 "Crear playlist"
$script:TEST_PLAYLIST_ID = $playlistData.id
Write-Host "Playlist creada con ID: $($script:TEST_PLAYLIST_ID)"

Print-Test "Obtener playlist por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/playlists/$($script:TEST_PLAYLIST_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener playlist por ID" | Out-Null

Print-Test "Obtener playlists de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/playlists/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener playlists de usuario" | Out-Null

Print-Test "Obtener playlists públicas"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/playlists/public" -Headers $authHeaders
Check-Response $response 200 "Obtener playlists públicas" | Out-Null

Print-Test "Agregar canción a playlist"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/playlists/$($script:TEST_PLAYLIST_ID)/songs/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Agregar canción a playlist" | Out-Null

Print-Test "Actualizar playlist"
$updatePlaylistBody = @{
    name = "Updated Playlist"
    description = "Updated description"
    isPublic = $false
}
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/playlists/$($script:TEST_PLAYLIST_ID)" -Headers $authHeaders -Body $updatePlaylistBody
Check-Response $response 200 "Actualizar playlist" | Out-Null

# ==============================================================================
# 9. STORE SERVICE - Tienda de Productos
# ==============================================================================

Print-Header "9. STORE SERVICE - Tienda de Productos"

Print-Test "Crear producto"
$productBody = @{
    artistId = 1
    name = "Test T-Shirt"
    description = "Test product description"
    category = "CLOTHING"
    price = 29.99
    stock = 100
    imageUrls = @("https://example.com/tshirt.jpg")
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/products" -Headers $authHeaders -Body $productBody
$productData = Check-Response $response 201 "Crear producto"
$script:TEST_PRODUCT_ID = $productData.id
Write-Host "Producto creado con ID: $($script:TEST_PRODUCT_ID)"

Print-Test "Obtener producto por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/products/$($script:TEST_PRODUCT_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener producto por ID" | Out-Null

Print-Test "Obtener todos los productos"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/products" -Headers $authHeaders
Check-Response $response 200 "Obtener todos los productos" | Out-Null

Print-Test "Obtener categorías de productos"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/products/categories" -Headers $authHeaders
Check-Response $response 200 "Obtener categorías" | Out-Null

Print-Test "Buscar productos"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/products?search=Test" -Headers $authHeaders
Check-Response $response 200 "Buscar productos" | Out-Null

Print-Test "Actualizar stock de producto"
$response = Invoke-ApiRequest -Method PATCH -Uri "$API_GATEWAY/api/products/$($script:TEST_PRODUCT_ID)/stock?stock=95" -Headers $authHeaders
Check-Response $response 200 "Actualizar stock" | Out-Null

Print-Test "Actualizar producto"
$updateProductBody = @{
    name = "Updated T-Shirt"
    description = "Updated description"
    price = 24.99
    stock = 95
}
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/products/$($script:TEST_PRODUCT_ID)" -Headers $authHeaders -Body $updateProductBody
Check-Response $response 200 "Actualizar producto" | Out-Null

# ==============================================================================
# 10. COMMUNICATION SERVICE - Comunicación
# ==============================================================================

Print-Header "10. COMMUNICATION SERVICE - Comunicación"

# === FAQ ===
Print-Test "Crear FAQ"
$faqBody = @{
    category = "GENERAL"
    question = "How do I create an account?"
    answer = "Click on the register button and fill in your details."
    language = "EN"
    order = 1
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/faq" -Headers $authHeaders -Body $faqBody
$faqData = Check-Response $response 200 "Crear FAQ"
$script:TEST_FAQ_ID = $faqData.id
Write-Host "FAQ creada con ID: $($script:TEST_FAQ_ID)"

Print-Test "Obtener FAQ por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/faq/$($script:TEST_FAQ_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener FAQ por ID" | Out-Null

Print-Test "Obtener todas las FAQs"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/faq" -Headers $authHeaders
Check-Response $response 200 "Obtener todas las FAQs" | Out-Null

Print-Test "Obtener FAQs por categoría"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/faq/category/GENERAL" -Headers $authHeaders
Check-Response $response 200 "Obtener FAQs por categoría" | Out-Null

Print-Test "Actualizar FAQ"
$updateFaqBody = @{
    question = "How do I create an account? (Updated)"
    answer = "Updated answer"
}
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/faq/$($script:TEST_FAQ_ID)" -Headers $authHeaders -Body $updateFaqBody
Check-Response $response 200 "Actualizar FAQ" | Out-Null

# === CONTACT ===
Print-Test "Crear mensaje de contacto"
$contactBody = @{
    userId = $script:TEST_USER_ID
    name = "Test User"
    email = "testuser@audira.com"
    subject = "Test Subject"
    message = "This is a test message"
    messageType = "GENERAL_INQUIRY"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/contact" -Headers $authHeaders -Body $contactBody
$contactData = Check-Response $response 200 "Crear mensaje de contacto"
$script:CONTACT_MESSAGE_ID = $contactData.id
Write-Host "Mensaje de contacto creado con ID: $($script:CONTACT_MESSAGE_ID)"

Print-Test "Obtener mensaje de contacto por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/contact/$($script:CONTACT_MESSAGE_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener mensaje por ID" | Out-Null

Print-Test "Obtener mensajes por usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/contact/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener mensajes por usuario" | Out-Null

Print-Test "Obtener mensajes pendientes"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/contact/pending" -Headers $authHeaders
Check-Response $response 200 "Obtener mensajes pendientes" | Out-Null

# === NOTIFICATIONS ===
Print-Test "Crear notificación"
$notificationBody = @{
    userId = $script:TEST_USER_ID
    type = "INFO"
    title = "Test Notification"
    message = "This is a test notification"
    priority = "MEDIUM"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/notifications" -Headers $authHeaders -Body $notificationBody
$notificationData = Check-Response $response 200 "Crear notificación"
$script:TEST_NOTIFICATION_ID = $notificationData.id
Write-Host "Notificación creada con ID: $($script:TEST_NOTIFICATION_ID)"

Print-Test "Obtener notificación por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/notifications/$($script:TEST_NOTIFICATION_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener notificación por ID" | Out-Null

Print-Test "Obtener notificaciones de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/notifications/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener notificaciones de usuario" | Out-Null

Print-Test "Obtener notificaciones no leídas"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/notifications/user/$($script:TEST_USER_ID)/unread" -Headers $authHeaders
Check-Response $response 200 "Obtener notificaciones no leídas" | Out-Null

Print-Test "Marcar notificación como leída"
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/notifications/$($script:TEST_NOTIFICATION_ID)/read" -Headers $authHeaders
Check-Response $response 200 "Marcar como leída" | Out-Null

# ==============================================================================
# 11. ORDER SERVICE - Órdenes
# ==============================================================================

Print-Header "11. ORDER SERVICE - Gestión de Órdenes"

Print-Test "Crear orden"
$orderBody = @{
    userId = $script:TEST_USER_ID
    items = @(
        @{
            itemType = "SONG"
            itemId = $script:TEST_SONG_ID
            quantity = 1
            price = 1.99
        }
    )
    shippingAddress = "123 Test Street, Test City, TC 12345"
}
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/orders" -Headers $authHeaders -Body $orderBody
$orderData = Check-Response $response 201 "Crear orden"
$script:TEST_ORDER_ID = $orderData.id
$script:ORDER_NUMBER = $orderData.orderNumber
Write-Host "Orden creada con ID: $($script:TEST_ORDER_ID), Número: $($script:ORDER_NUMBER)"

Print-Test "Obtener orden por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/orders/$($script:TEST_ORDER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener orden por ID" | Out-Null

Print-Test "Obtener orden por número"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/orders/order-number/$($script:ORDER_NUMBER)" -Headers $authHeaders
Check-Response $response 200 "Obtener orden por número" | Out-Null

Print-Test "Obtener todas las órdenes"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/orders" -Headers $authHeaders
Check-Response $response 200 "Obtener todas las órdenes" | Out-Null

Print-Test "Obtener órdenes de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/orders/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener órdenes de usuario" | Out-Null

Print-Test "Obtener órdenes por estado"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/orders/status/PENDING" -Headers $authHeaders
Check-Response $response 200 "Obtener órdenes por estado" | Out-Null

Print-Test "Actualizar estado de orden"
$orderStatusBody = @{
    status = "PROCESSING"
}
$response = Invoke-ApiRequest -Method PUT -Uri "$API_GATEWAY/api/orders/$($script:TEST_ORDER_ID)/status" -Headers $authHeaders -Body $orderStatusBody
Check-Response $response 200 "Actualizar estado de orden" | Out-Null

# ==============================================================================
# 12. PAYMENT SERVICE - Pagos
# ==============================================================================

Print-Header "12. PAYMENT SERVICE - Procesamiento de Pagos"

Print-Test "Crear pago"
# --- CORRECCIÓN AQUÍ ---
# Faltaba escapar los ampersands
$paymentParams = "orderId=$($script:TEST_ORDER_ID)`&userId=$($script:TEST_USER_ID)`&amount=1.99`&paymentMethod=CREDIT_CARD"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/payments?$paymentParams" -Headers $authHeaders -ContentType "application/x-www-form-urlencoded"
$paymentData = Check-Response $response 200 "Crear pago"
$script:TEST_PAYMENT_ID = $paymentData.id
$script:TRANSACTION_ID = $paymentData.transactionId
Write-Host "Pago creado con ID: $($script:TEST_PAYMENT_ID), Transaction ID: $($script:TRANSACTION_ID)"

Print-Test "Obtener pago por ID"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/payments/$($script:TEST_PAYMENT_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener pago por ID" | Out-Null

Print-Test "Obtener pago por orden"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/payments/order/$($script:TEST_ORDER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener pago por orden" | Out-Null

Print-Test "Obtener pagos de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/payments/user/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener pagos de usuario" | Out-Null

Print-Test "Procesar pago"
$processParams = "transactionId=TXN-TEST-12345"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/payments/$($script:TEST_PAYMENT_ID)/process?$processParams" -Headers $authHeaders -ContentType "application/x-www-form-urlencoded"
Check-Response $response 200 "Procesar pago" | Out-Null

Print-Test "Completar pago"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/payments/$($script:TEST_PAYMENT_ID)/complete" -Headers $authHeaders
Check-Response $response 200 "Completar pago" | Out-Null

# ==============================================================================
# 13. METRICS SERVICE - Métricas
# ==============================================================================

Print-Header "13. METRICS SERVICE - Métricas y Estadísticas"

# === USER METRICS ===
Print-Test "Obtener métricas de usuario"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/metrics/users/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener métricas de usuario" | Out-Null

Print-Test "Incrementar reproducciones de usuario"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/users/$($script:TEST_USER_ID)/plays" -Headers $authHeaders
Check-Response $response 200 "Incrementar reproducciones" | Out-Null

Print-Test "Agregar tiempo de escucha"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/users/$($script:TEST_USER_ID)/listening-time?seconds=120" -Headers $authHeaders
Check-Response $response 200 "Agregar tiempo de escucha" | Out-Null

Print-Test "Incrementar seguidores"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/users/$($script:TEST_USER_ID)/followers/increment" -Headers $authHeaders
Check-Response $response 200 "Incrementar seguidores" | Out-Null

Print-Test "Incrementar siguiendo"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/users/$($script:TEST_USER_ID)/following/increment" -Headers $authHeaders
Check-Response $response 200 "Incrementar siguiendo" | Out-Null

Print-Test "Incrementar compras"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/users/$($script:TEST_USER_ID)/purchases" -Headers $authHeaders
Check-Response $response 200 "Incrementar compras" | Out-Null

# === ARTIST METRICS ===
Print-Test "Obtener métricas de artista"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/metrics/artists/1" -Headers $authHeaders
Check-Response $response 200 "Obtener métricas de artista" | Out-Null

Print-Test "Incrementar reproducciones de artista"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/artists/1/plays" -Headers $authHeaders
Check-Response $response 200 "Incrementar reproducciones de artista" | Out-Null

Print-Test "Incrementar oyentes de artista"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/artists/1/listeners" -Headers $authHeaders
Check-Response $response 200 "Incrementar oyentes" | Out-Null

Print-Test "Incrementar seguidores de artista"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/artists/1/followers/increment" -Headers $authHeaders
Check-Response $response 200 "Incrementar seguidores de artista" | Out-Null

Print-Test "Agregar venta de artista"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/artists/1/sales?amount=9.99" -Headers $authHeaders
Check-Response $response 200 "Agregar venta de artista" | Out-Null

# === SONG METRICS ===
Print-Test "Obtener métricas de canción"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/metrics/songs/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Obtener métricas de canción" | Out-Null

Print-Test "Incrementar reproducciones de canción"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/songs/$($script:TEST_SONG_ID)/plays" -Headers $authHeaders
Check-Response $response 200 "Incrementar reproducciones de canción" | Out-Null

Print-Test "Incrementar oyentes únicos"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/songs/$($script:TEST_SONG_ID)/listeners" -Headers $authHeaders
Check-Response $response 200 "Incrementar oyentes únicos" | Out-Null

Print-Test "Incrementar likes de canción"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/songs/$($script:TEST_SONG_ID)/likes" -Headers $authHeaders
Check-Response $response 200 "Incrementar likes" | Out-Null

Print-Test "Incrementar compartidos"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/songs/$($script:TEST_SONG_ID)/shares" -Headers $authHeaders
Check-Response $response 200 "Incrementar compartidos" | Out-Null

Print-Test "Incrementar descargas"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/metrics/songs/$($script:TEST_SONG_ID)/downloads" -Headers $authHeaders
Check-Response $response 200 "Incrementar descargas" | Out-Null

# === GLOBAL METRICS ===
Print-Test "Obtener métricas globales"
$response = Invoke-ApiRequest -Method GET -Uri "$API_GATEWAY/api/metrics/global" -Headers $authHeaders
Check-Response $response 200 "Obtener métricas globales" | Out-Null

# ==============================================================================
# 14. PRUEBAS DE LIMPIEZA (DELETES)
# ==============================================================================

Print-Header "14. PRUEBAS DE ELIMINACIÓN - Limpieza de Datos de Prueba"

Print-Test "Eliminar comentario"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/comments/$($script:TEST_COMMENT_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar comentario" | Out-Null

Print-Test "Eliminar calificación"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/ratings/$($script:TEST_RATING_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar calificación" | Out-Null

Print-Test "Eliminar canción de playlist"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/playlists/$($script:TEST_PLAYLIST_ID)/songs/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Eliminar canción de playlist" | Out-Null

Print-Test "Eliminar playlist"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/playlists/$($script:TEST_PLAYLIST_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar playlist" | Out-Null

Print-Test "Eliminar item de colección"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/library/collections/$($script:TEST_COLLECTION_ID)/items/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 200 "Eliminar item de colección" | Out-Null

Print-Test "Eliminar colección"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/library/collections/$($script:TEST_COLLECTION_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar colección" | Out-Null

Print-Test "Eliminar de biblioteca"
# --- CORRECCIÓN AQUÍ ---
# Faltaba escapar los ampersands
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/library?userId=$($script:TEST_USER_ID)`&itemType=SONG`&itemId=$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar de biblioteca" | Out-Null

if (![string]::IsNullOrEmpty($script:CART_ITEM_ID)) {
    Print-Test "Eliminar item del carrito"
    $response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/cart/$($script:TEST_USER_ID)/items/$($script:CART_ITEM_ID)" -Headers $authHeaders
    Check-Response $response 200 "Eliminar item del carrito" | Out-Null
}

Print-Test "Limpiar carrito"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/cart/$($script:TEST_USER_ID)" -Headers $authHeaders
Check-Response $response 204 "Limpiar carrito" | Out-Null

Print-Test "Eliminar producto"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/products/$($script:TEST_PRODUCT_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar producto" | Out-Null

Print-Test "Eliminar FAQ"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/faq/$($script:TEST_FAQ_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar FAQ" | Out-Null

Print-Test "Eliminar notificación"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/notifications/$($script:TEST_NOTIFICATION_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar notificación" | Out-Null

Print-Test "Cancelar orden"
$response = Invoke-ApiRequest -Method POST -Uri "$API_GATEWAY/api/orders/$($script:TEST_ORDER_ID)/cancel" -Headers $authHeaders
Check-Response $response 200 "Cancelar orden" | Out-Null

Print-Test "Eliminar colaboración"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/collaborations/$($script:TEST_COLLABORATION_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar colaboración" | Out-Null

Print-Test "Eliminar canción"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/songs/$($script:TEST_SONG_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar canción" | Out-Null

Print-Test "Eliminar álbum"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/albums/$($script:TEST_ALBUM_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar álbum" | Out-Null

Print-Test "Eliminar género"
$response = Invoke-ApiRequest -Method DELETE -Uri "$API_GATEWAY/api/genres/$($script:TEST_GENRE_ID)" -Headers $authHeaders
Check-Response $response 204 "Eliminar género" | Out-Null

# ==============================================================================
# RESUMEN FINAL
# ==============================================================================

Print-Header "RESUMEN DE PRUEBAS"

Write-Host @"
╔════════════════════════════════════════════════╗
║                                                ║
║           🎉 TODAS LAS PRUEBAS PASARON 🎉            ║
║                                                ║
╚════════════════════════════════════════════════╝
"@ -ForegroundColor Green

Write-Host ""
Write-Host "Total de pruebas ejecutadas: " -NoNewline -ForegroundColor Cyan
Write-Host "$($script:TOTAL_TESTS)" -ForegroundColor Magenta
Write-Host "Pruebas exitosas: " -NoNewline -ForegroundColor Cyan
Write-Host "$($script:PASSED_TESTS)" -ForegroundColor Green
Write-Host "Pruebas fallidas: " -NoNewline -ForegroundColor Cyan
Write-Host "0" -ForegroundColor Green
Write-Host ""
Write-Host "Servicios probados:" -ForegroundColor Yellow
Write-Host "   ✓ Config Server" -ForegroundColor Green
Write-Host "   ✓ Eureka Discovery Server" -ForegroundColor Green
Write-Host "   ✓ API Gateway" -ForegroundColor Green
Write-Host "   ✓ User Service (Autenticación y Usuarios)" -ForegroundColor Green
Write-Host "   ✓ Catalog Service (Géneros, Álbumes, Canciones, Colaboraciones)" -ForegroundColor Green
Write-Host "   ✓ Player Service (Reproducción, Cola, Historial)" -ForegroundColor Green
Write-Host "   ✓ Library Service (Biblioteca y Colecciones)" -ForegroundColor Green
Write-Host "   ✓ Ratings Service (Calificaciones y Comentarios)" -ForegroundColor Green
Write-Host "   ✓ Cart Service (Carrito de Compras)" -ForegroundColor Green
Write-Host "   ✓ Playlist Service (Listas de Reproducción)" -ForegroundColor Green
Write-Host "   ✓ Store Service (Tienda de Productos)" -ForegroundColor Green
Write-Host "   ✓ Communication Service (FAQ, Contacto, Notificaciones)" -ForegroundColor Green
Write-Host "   ✓ Order Service (Gestión de Órdenes)" -ForegroundColor Green
Write-Host "   ✓ Payment Service (Procesamiento de Pagos)" -ForegroundColor Green
Write-Host "   ✓ Metrics Service (Métricas de Usuario, Artista, Canción, Global)" -ForegroundColor Green
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "El sistema Audira está funcionando perfectamente!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""