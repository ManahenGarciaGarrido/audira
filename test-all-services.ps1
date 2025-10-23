# Configuración inicial
$baseUrl = "http://localhost:8080"
$VerbosePreference = "Continue" # Muestra más detalles de Invoke-RestMethod
$global:jwtToken = $null # Variable global para guardar el token JWT

# --- Funciones de Ayuda ---
function Print-Header($title) {
    Write-Host "`n"
    Write-Host "=================================================="
    Write-Host "  TESTING: $title"
    Write-Host "=================================================="
}

function Invoke-ApiRequest {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Method,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [object]$Body = $null,
        [switch]$RequiresJwt
    )

    $uri = "$baseUrl$Path"
    $headers = @{}
    $contentType = "application/json"

    # Añadir token si es necesario y si lo tenemos
    if ($RequiresJwt.IsPresent -and $global:jwtToken) {
        $headers.Add("Authorization", "Bearer $($global:jwtToken)")
        Write-Verbose "Using JWT Token for request."
    } elseif ($RequiresJwt.IsPresent -and !$global:jwtToken) {
        Write-Warning "JWT Token required but not available for $Path. Skipping Auth header."
        # Decide si continuar o fallar aquí si es estrictamente necesario
    }

    $params = @{
        Uri         = $uri
        Method      = $Method
        Headers     = $headers
        ContentType = $contentType
        Verbose     = $true # Para ver detalles de la petición y respuesta
        ErrorAction = 'SilentlyContinue' # Para capturar errores HTTP
    }

    if ($Body) {
        $params.Add("Body", ($Body | ConvertTo-Json -Depth 5))
    }

    Write-Host "`n[$Method] $Path"
    if($Body) { Write-Host "Body: $($params.Body)"}

    try {
        $response = Invoke-RestMethod @params

        Write-Host "Response Status: OK" # Asume OK si no hay excepción
        Write-Host "Response Body:"
        Write-Output ($response | ConvertTo-Json -Depth 5)

        # Capturar token si es una respuesta de login/registro
        if ($response -is [pscustomobject] -and $response.PSObject.Properties.Name -contains 'token') {
             $global:jwtToken = $response.token
             Write-Host "JWT Token Captured!"
        }
        return $response
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription
        Write-Error "Request failed! Status: $statusCode ($statusDescription)"
        Write-Error "Response Body: $($_.ErrorDetails.Message)"
        # Puedes añadir -ErrorAction Stop aquí si quieres que el script pare en el primer error
    }
     Write-Host "--------------------------------------------------"
     return $null # Devuelve null en caso de error
}

# ================================================
# INICIO DE LAS PRUEBAS
# ================================================

# --- Infraestructura (Opcional) ---
Print-Header "Infrastructure Checks"
Invoke-ApiRequest -Method GET -Path "/actuator/health" # Probando el Gateway
# Podrías añadir pruebas directas a Eureka (8761) y Config Server (8888) si quieres

# --- ÉPICA 1: Community Service ---
Print-Header "Community Service - Auth & Users"

# 1. Registrar Usuario
$registerBody = @{
    email     = "testuser@example.com"
    username  = "testuserps1"
    password  = "Password123!"
    firstName = "Test"
    lastName  = "UserPS"
    role      = "USER"
}
$registerResponse = Invoke-ApiRequest -Method POST -Path "/api/users/auth/register" -Body $registerBody
$userIdToTest = $null # Inicializar a null
if ($registerResponse -and $registerResponse.user -and $registerResponse.user.id) {
    $userIdToTest = $registerResponse.user.id # Intentar capturar el ID del usuario creado
    Write-Host "Captured User ID: $userIdToTest"
} else {
     Write-Warning "User ID not captured from registration response."
}


# 2. Login
$loginBody = @{
    emailOrUsername = "testuser@example.com"
    password        = "Password123!"
}
Invoke-ApiRequest -Method POST -Path "/api/users/auth/login" -Body $loginBody

# 3. Ver Perfil Actual #[REQUIERE JWT]#
Invoke-ApiRequest -Method GET -Path "/api/users/profile" -RequiresJwt

# 4. Ver Perfil de Otro Usuario (usando el ID capturado) #[REQUIERE JWT]#
if ($userIdToTest) {
    Invoke-ApiRequest -Method GET -Path "/api/users/$userIdToTest" -RequiresJwt # <-- Añadido -RequiresJwt
} else {
    Write-Warning "Cannot test GET /api/users/{id} because user ID was not captured from registration."
}

# 5. Actualizar Perfil #[REQUIERE JWT]#
$updateProfileBody = @{
    firstName = "Test-Updated"
    lastName  = "UserPS-Updated"
    bio       = "Bio de prueba"
}
Invoke-ApiRequest -Method PUT -Path "/api/users/profile" -Body $updateProfileBody -RequiresJwt

# --- Community Service - Métricas ---
Print-Header "Community Service - Metrics"
# Asumiendo IDs de ejemplo - Estas podrían requerir JWT dependiendo de tu implementación
Invoke-ApiRequest -Method GET -Path "/api/metrics/users/1" #-RequiresJwt
Invoke-ApiRequest -Method GET -Path "/api/metrics/artists/1" #-RequiresJwt
Invoke-ApiRequest -Method GET -Path "/api/metrics/songs/1" #-RequiresJwt
Invoke-ApiRequest -Method GET -Path "/api/metrics/global" #-RequiresJwt

# --- Community Service - Valoraciones y Comentarios ---
Print-Header "Community Service - Ratings & Comments"
# Crear Valoración #[REQUIERE JWT]#
$ratingBody = @{
    userId     = $userIdToTest # Usar ID capturado si es posible
    entityType = "SONG"
    entityId   = 1 # Asume entidad 1 existe
    rating     = 5
}
# Solo intentar si tenemos userIdToTest
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/ratings" -Body $ratingBody -RequiresJwt}


# Crear Comentario #[REQUIERE JWT]#
$commentBody = @{
    userId     = $userIdToTest # Usar ID capturado si es posible
    entityType = "SONG"
    entityId   = 1 # Asume entidad 1 existe
    content    = "Comentario desde PowerShell"
}
# Solo intentar si tenemos userIdToTest
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/comments" -Body $commentBody -RequiresJwt}

# Ver Valoraciones por Entidad (Suele ser público)
Invoke-ApiRequest -Method GET -Path "/api/ratings/entity/SONG/1"
# Ver Comentarios por Entidad (Suele ser público)
Invoke-ApiRequest -Method GET -Path "/api/comments/entity/SONG/1"

# --- ÉPICA 2: Music Catalog Service ---
Print-Header "Music Catalog Service"

# Listar Géneros (Suele ser público)
Invoke-ApiRequest -Method GET -Path "/api/genres"
# Crear Género #[REQUIERE JWT - Probablemente rol ADMIN/ARTIST]#
$genreBody = @{
    name        = "PowerShell Rock"
    description = "Genre created by script"
    imageUrl    = "http://example.com/psrock.jpg"
}
Invoke-ApiRequest -Method POST -Path "/api/genres" -Body $genreBody -RequiresJwt

# Listar Canciones (Suele ser público)
Invoke-ApiRequest -Method GET -Path "/api/songs"
# Crear Canción #[REQUIERE JWT - Probablemente rol ARTIST]#
$songBody = @{
    title       = "PS Song"
    artistId    = $userIdToTest # Asume que el usuario de prueba es el artista
    albumId     = 1 # Asume album 1 existe
    genreIds    = @(1) # Asume genre 1 existe
    duration    = 180
    audioUrl    = "http://example.com/pssong.mp3"
    price       = 1.29
    trackNumber = 1
}
# Solo intentar si tenemos userIdToTest
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/songs" -Body $songBody -RequiresJwt}
$songIdToTest = 1 # Asumiendo ID=1 para simplificar, idealmente capturar de la respuesta anterior

# Crear Album #[REQUIERE JWT - Probablemente rol ARTIST]#
$albumBody = @{
    title       = "PS Album"
    artistId    = $userIdToTest # Asume que el usuario de prueba es el artista
    genreIds    = @(1)
    releaseDate = "2025-10-23" # O el formato que espere tu API
}
# Solo intentar si tenemos userIdToTest
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/albums" -Body $albumBody -RequiresJwt}
$albumIdToTest = 1 # Asumiendo ID=1

# Añadir Colaborador #[REQUIERE JWT - Probablemente rol ARTIST]#
$collabBody = @{
    songId          = $songIdToTest # Usar ID capturado idealmente
    artistId        = $userIdToTest + 1 # Asume artista ID+1 existe
    artistName      = "PS Collaborator"
    collaborationType = "FEATURED_ARTIST"
}
# Solo intentar si tenemos IDs necesarios
if ($songIdToTest -and $userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/collaborations" -Body $collabBody -RequiresJwt}


# Buscar Música (Público)
Invoke-ApiRequest -Method GET -Path "/api/discovery/search?query=ps"
# Música en Tendencia (Público)
Invoke-ApiRequest -Method GET -Path "/api/discovery/trending"

# --- ÉPICA 3: Playback Service ---
Print-Header "Playback Service"
# Asume songId=1 y songId=2 existen

# Iniciar Reproducción #[REQUIERE JWT]#
if ($userIdToTest -and $songIdToTest){Invoke-ApiRequest -Method POST -Path "/api/playback/play?userId=$userIdToTest&songId=$songIdToTest" -RequiresJwt}
# Pausar #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/playback/pause?userId=$userIdToTest" -RequiresJwt}
# Siguiente Canción #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/playback/next?userId=$userIdToTest" -RequiresJwt}

# Añadir a Cola #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/queue?userId=$userIdToTest&songId=2" -RequiresJwt} # Asume songId=2 existe
# Ver Cola #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method GET -Path "/api/queue/$userIdToTest" -RequiresJwt}
# Ver Historial #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method GET -Path "/api/history/user/$userIdToTest" -RequiresJwt}
# Ver Biblioteca #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method GET -Path "/api/library/$userIdToTest" -RequiresJwt}

# Crear Playlist #[REQUIERE JWT]#
$playlistBody = @{
    userId      = $userIdToTest
    name        = "PS Playlist"
    description = "Test playlist from PS"
    isPublic    = $true
}
$playlistResponse = $null
if ($userIdToTest) {$playlistResponse = Invoke-ApiRequest -Method POST -Path "/api/playlists" -Body $playlistBody -RequiresJwt}
$playlistIdToTest = $null
if ($playlistResponse -and $playlistResponse.id) {
    $playlistIdToTest = $playlistResponse.id # Intentar capturar ID
    Write-Host "Captured Playlist ID: $playlistIdToTest"
} else {
     Write-Warning "Playlist ID not captured from creation response."
}


# Añadir Canción a Playlist #[REQUIERE JWT]#
if ($playlistIdToTest -and $songIdToTest) {
    $addSongBody = @{ songId = $songIdToTest }
    Invoke-ApiRequest -Method POST -Path "/api/playlists/$playlistIdToTest/songs" -Body $addSongBody -RequiresJwt
} else {
    Write-Warning "Cannot test Add Song to Playlist because Playlist ID or Song ID was not captured."
}

# --- ÉPICA 4: Commerce Service ---
Print-Header "Commerce Service"

# Listar Productos (Suele ser público)
Invoke-ApiRequest -Method GET -Path "/api/products"
# Crear Producto #[REQUIERE JWT - Probablemente rol ARTIST/ADMIN]#
$productBody = @{
    artistId  = $userIdToTest # Asume el usuario de prueba es el vendedor
    name      = "PS T-Shirt"
    category  = "CLOTHING"
    price     = 19.99
    stock     = 50
    imageUrls = @("http://example.com/psshirt.jpg")
}
if ($userIdToTest){Invoke-ApiRequest -Method POST -Path "/api/products" -Body $productBody -RequiresJwt}
$productIdToTest = 1 # Asumiendo ID=1

# Ver Carrito #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method GET -Path "/api/cart/$userIdToTest" -RequiresJwt}
# Añadir al Carrito #[REQUIERE JWT]#
$cartItemBody = @{
    userId   = $userIdToTest
    itemType = "SONG"
    itemId   = $songIdToTest # Usar ID capturado idealmente
    quantity = 1
    # price    = 1.29 # Quitado, el backend debería saber el precio
}
if ($userIdToTest -and $songIdToTest){Invoke-ApiRequest -Method POST -Path "/api/cart/items" -Body $cartItemBody -RequiresJwt}

# Crear Pedido #[REQUIERE JWT]#
$orderBody = @{
    userId          = $userIdToTest
    items           = @(
        @{ itemType="SONG"; itemId=$songIdToTest; quantity=1 } # Quitado price
    )
    shippingAddress = "PS Test Address 123"
}
$orderResponse = $null
if ($userIdToTest -and $songIdToTest) {$orderResponse = Invoke-ApiRequest -Method POST -Path "/api/orders" -Body $orderBody -RequiresJwt}
$orderIdToTest = $null
if ($orderResponse -and $orderResponse.id){
     $orderIdToTest = $orderResponse.id # Intentar capturar ID
     Write-Host "Captured Order ID: $orderIdToTest"
} else {
     Write-Warning "Order ID not captured from creation response."
}

# Ver Pedidos del Usuario #[REQUIERE JWT]#
if ($userIdToTest){Invoke-ApiRequest -Method GET -Path "/api/orders/user/$userIdToTest" -RequiresJwt}

# Procesar Pago #[REQUIERE JWT]#
if ($orderIdToTest -and $orderResponse) {
    $paymentBody = @{
        orderId       = $orderIdToTest
        amount        = $orderResponse.totalAmount # Usar el totalAmount de la respuesta anterior
        paymentMethod = "CREDIT_CARD" # O el método que soporte tu API
    }
    Invoke-ApiRequest -Method POST -Path "/api/payments" -Body $paymentBody -RequiresJwt
} else {
     Write-Warning "Cannot test Payment because Order ID or Order Response was not captured."
}


# --- Limpieza (Opcional pero Recomendado) ---
Print-Header "Cleanup"
# Borrar el usuario creado al principio #[REQUIERE JWT]#
if ($userIdToTest) {
    Write-Host "Attempting to delete user ID: $userIdToTest"
    Invoke-ApiRequest -Method DELETE -Path "/api/users/$userIdToTest" -RequiresJwt
} else {
    Write-Warning "Skipping user deletion because user ID was not captured."
}

Write-Host "`n"
Write-Host "=================================================="
Write-Host "  TEST SCRIPT FINISHED"
Write-Host "=================================================="

