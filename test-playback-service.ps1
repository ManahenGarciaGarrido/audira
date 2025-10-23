# ================================================================
# Test Script para Playback Service - Puerto 9003
# ================================================================
# Este script prueba todos los endpoints del microservicio Playback Service
# directamente sin pasar por el API Gateway
# ================================================================

$baseUrl = "http://localhost:9003"
$VerbosePreference = "Continue"
$global:testUserId = 1  # Usuario de prueba
$global:testSongId = 1  # Canción de prueba
$global:testPlaylistId = $null
$global:testSessionId = $null
$global:testCollectionId = $null

# --- Funciones de Ayuda ---
function Print-Header($title) {
    Write-Host "`n"
    Write-Host "=================================================================="
    Write-Host "  TESTING: $title"
    Write-Host "=================================================================="
}

function Invoke-ApiRequest {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Method,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [object]$Body = $null
    )

    $uri = "$baseUrl$Path"
    $headers = @{}
    $contentType = "application/json"

    $params = @{
        Uri         = $uri
        Method      = $Method
        Headers     = $headers
        ContentType = $contentType
        Verbose     = $true
        ErrorAction = 'SilentlyContinue'
    }

    if ($Body) {
        $params.Add("Body", ($Body | ConvertTo-Json -Depth 5))
    }

    Write-Host "`n[$Method] $Path"
    if($Body) {
        Write-Host "Body: $($params.Body)"
    }

    try {
        $response = Invoke-RestMethod @params
        Write-Host "Response Status: OK"
        Write-Host "Response Body:"
        Write-Output ($response | ConvertTo-Json -Depth 5)

        if ($response -is [pscustomobject] -and $response.PSObject.Properties.Name -contains 'id') {
            Write-Host "Entity ID: $($response.id)"
        }

        return $response
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription
        Write-Error "Request failed! Status: $statusCode ($statusDescription)"
        Write-Error "Response Body: $($_.ErrorDetails.Message)"
    }
    Write-Host "--------------------------------------------------"
    return $null
}

# ================================================================
# INICIO DE LAS PRUEBAS
# ================================================================

Print-Header "PLAYBACK SERVICE - Playback Control"

# --- PlaybackController: /api/playback ---
Write-Host "`n=== PlaybackController ==="

# 1. Iniciar Reproducción
$playbackResponse = Invoke-ApiRequest -Method POST -Path "/api/playback/play?userId=$global:testUserId&songId=$global:testSongId&duration=210"
if ($playbackResponse) { $global:testSessionId = $playbackResponse.id }

# 2. Obtener Sesión Actual de Usuario
Invoke-ApiRequest -Method GET -Path "/api/playback/current/$global:testUserId"

# 3. Obtener Sesiones de Usuario
Invoke-ApiRequest -Method GET -Path "/api/playback/sessions/$global:testUserId"

# 4. Pausar Reproducción
if ($global:testSessionId) {
    Invoke-ApiRequest -Method PUT -Path "/api/playback/$global:testSessionId/pause"
}

# 5. Reanudar Reproducción
if ($global:testSessionId) {
    Invoke-ApiRequest -Method PUT -Path "/api/playback/$global:testSessionId/resume"
}

# 6. Buscar en Reproducción
if ($global:testSessionId) {
    Invoke-ApiRequest -Method PUT -Path "/api/playback/$global:testSessionId/seek?time=60"
}

# 7. Detener Reproducción
if ($global:testSessionId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/playback/$global:testSessionId"
}

Print-Header "PLAYBACK SERVICE - Playlists"

# --- PlaylistController: /api/playlists ---
Write-Host "`n=== PlaylistController ==="

# 8. Crear Playlist
$playlistBody = @{
    userId      = $global:testUserId
    name        = "Test Playlist"
    description = "Playlist for testing purposes"
    isPublic    = $true
}
$playlistResponse = Invoke-ApiRequest -Method POST -Path "/api/playlists" -Body $playlistBody
if ($playlistResponse) { $global:testPlaylistId = $playlistResponse.id }

# 9. Listar Todas las Playlists
Invoke-ApiRequest -Method GET -Path "/api/playlists"

# 10. Obtener Playlist por ID
if ($global:testPlaylistId) {
    Invoke-ApiRequest -Method GET -Path "/api/playlists/$global:testPlaylistId"
}

# 11. Obtener Playlists de Usuario
Invoke-ApiRequest -Method GET -Path "/api/playlists/user/$global:testUserId"

# 12. Obtener Playlists Públicas
Invoke-ApiRequest -Method GET -Path "/api/playlists/public"

# 13. Obtener Playlists Públicas de Usuario
Invoke-ApiRequest -Method GET -Path "/api/playlists/public/user/$global:testUserId"

# 14. Añadir Canción a Playlist
if ($global:testPlaylistId) {
    $addSongBody = @{
        songId   = $global:testSongId
        position = 1
    }
    Invoke-ApiRequest -Method POST -Path "/api/playlists/$global:testPlaylistId/songs" -Body $addSongBody
}

# 15. Obtener Canciones de Playlist
if ($global:testPlaylistId) {
    Invoke-ApiRequest -Method GET -Path "/api/playlists/$global:testPlaylistId/songs"
}

# 16. Actualizar Playlist
if ($global:testPlaylistId) {
    $updatePlaylistBody = @{
        name        = "Test Playlist (Updated)"
        description = "Updated playlist description"
        isPublic    = $false
    }
    Invoke-ApiRequest -Method PUT -Path "/api/playlists/$global:testPlaylistId" -Body $updatePlaylistBody
}

# 17. Reordenar Canciones en Playlist
if ($global:testPlaylistId) {
    $reorderBody = @{
        songIds = @($global:testSongId)
    }
    Invoke-ApiRequest -Method PUT -Path "/api/playlists/$global:testPlaylistId/songs/reorder" -Body $reorderBody
}

# 18. Eliminar Canción de Playlist
if ($global:testPlaylistId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/playlists/$global:testPlaylistId/songs/$global:testSongId"
}

Print-Header "PLAYBACK SERVICE - Library"

# --- LibraryController: /api/library ---
Write-Host "`n=== LibraryController ==="

# 19. Añadir a Biblioteca
Invoke-ApiRequest -Method POST -Path "/api/library/items?userId=$global:testUserId&itemType=SONG&itemId=$global:testSongId"

# 20. Obtener Biblioteca de Usuario
Invoke-ApiRequest -Method GET -Path "/api/library/user/$global:testUserId"

# 21. Obtener Biblioteca por Tipo
Invoke-ApiRequest -Method GET -Path "/api/library/user/$global:testUserId/type/SONG"

# 22. Obtener Favoritos
Invoke-ApiRequest -Method GET -Path "/api/library/user/$global:testUserId/favorites"

# 23. Alternar Favorito
Invoke-ApiRequest -Method PUT -Path "/api/library/items/favorite?userId=$global:testUserId&itemType=SONG&itemId=$global:testSongId"

# 24. Eliminar de Biblioteca
Invoke-ApiRequest -Method DELETE -Path "/api/library/items?userId=$global:testUserId&itemType=SONG&itemId=$global:testSongId"

Print-Header "PLAYBACK SERVICE - Queue"

# --- QueueController: /api/queue ---
Write-Host "`n=== QueueController ==="

# 25. Obtener Cola
Invoke-ApiRequest -Method GET -Path "/api/queue/$global:testUserId"

# 26. Añadir a Cola
Invoke-ApiRequest -Method POST -Path "/api/queue?userId=$global:testUserId&songId=$global:testSongId"

# 27. Añadir Otra Canción a Cola
Invoke-ApiRequest -Method POST -Path "/api/queue?userId=$global:testUserId&songId=2"

# 28. Establecer Índice Actual
Invoke-ApiRequest -Method PUT -Path "/api/queue/$global:testUserId/index?index=0"

# 29. Activar Aleatorio
Invoke-ApiRequest -Method PUT -Path "/api/queue/$global:testUserId/shuffle?shuffle=true"

# 30. Desactivar Aleatorio
Invoke-ApiRequest -Method PUT -Path "/api/queue/$global:testUserId/shuffle?shuffle=false"

# 31. Establecer Modo de Repetición
Invoke-ApiRequest -Method PUT -Path "/api/queue/$global:testUserId/repeat?repeatMode=ALL"

# 32. Cambiar Modo de Repetición
Invoke-ApiRequest -Method PUT -Path "/api/queue/$global:testUserId/repeat?repeatMode=ONE"

# 33. Eliminar de Cola
Invoke-ApiRequest -Method DELETE -Path "/api/queue?userId=$global:testUserId&songId=2"

# 34. Limpiar Cola
Invoke-ApiRequest -Method DELETE -Path "/api/queue/$global:testUserId/clear"

Print-Header "PLAYBACK SERVICE - History"

# --- HistoryController: /api/history ---
Write-Host "`n=== HistoryController ==="

# 35. Registrar Reproducción
Invoke-ApiRequest -Method POST -Path "/api/history?userId=$global:testUserId&songId=$global:testSongId&completionPercentage=85"

# 36. Registrar Otra Reproducción
Invoke-ApiRequest -Method POST -Path "/api/history?userId=$global:testUserId&songId=2&completionPercentage=100"

# 37. Obtener Historial de Usuario
Invoke-ApiRequest -Method GET -Path "/api/history/user/$global:testUserId"

# 38. Obtener Historial Reciente
Invoke-ApiRequest -Method GET -Path "/api/history/user/$global:testUserId/recent?limit=10"

# 39. Obtener Historial Reciente con Límite Diferente
Invoke-ApiRequest -Method GET -Path "/api/history/user/$global:testUserId/recent?limit=5"

Print-Header "PLAYBACK SERVICE - Collections"

# --- CollectionController: /api/library/collections ---
Write-Host "`n=== CollectionController ==="

# 40. Crear Colección
$collectionBody = @{
    userId      = $global:testUserId
    name        = "Test Collection"
    description = "Collection for testing"
    type        = "CUSTOM"
}
$collectionResponse = Invoke-ApiRequest -Method POST -Path "/api/library/collections" -Body $collectionBody
if ($collectionResponse) { $global:testCollectionId = $collectionResponse.id }

# 41. Obtener Colección por ID
if ($global:testCollectionId) {
    Invoke-ApiRequest -Method GET -Path "/api/library/collections/$global:testCollectionId"
}

# 42. Obtener Colecciones de Usuario
Invoke-ApiRequest -Method GET -Path "/api/library/collections/user/$global:testUserId"

# 43. Actualizar Colección
if ($global:testCollectionId) {
    $updateCollectionBody = @{
        userId      = $global:testUserId
        name        = "Test Collection (Updated)"
        description = "Updated collection description"
        type        = "CUSTOM"
    }
    Invoke-ApiRequest -Method PUT -Path "/api/library/collections/$global:testCollectionId" -Body $updateCollectionBody
}

# 44. Añadir Item a Colección
if ($global:testCollectionId) {
    Invoke-ApiRequest -Method POST -Path "/api/library/collections/$global:testCollectionId/items?itemId=$global:testSongId"
}

# 45. Eliminar Item de Colección
if ($global:testCollectionId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/library/collections/$global:testCollectionId/items/$global:testSongId"
}

Print-Header "PLAYBACK SERVICE - Cleanup"

# --- Limpieza ---
Write-Host "`n=== Cleanup ==="

# Limpiar Historial
Invoke-ApiRequest -Method DELETE -Path "/api/history/user/$global:testUserId"

# Limpiar Biblioteca
Invoke-ApiRequest -Method DELETE -Path "/api/library/user/$global:testUserId"

# Eliminar Colección
if ($global:testCollectionId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/library/collections/$global:testCollectionId"
}

# Eliminar Playlist
if ($global:testPlaylistId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/playlists/$global:testPlaylistId"
}

Write-Host "`n"
Write-Host "=================================================================="
Write-Host "  PLAYBACK SERVICE TEST SCRIPT FINISHED"
Write-Host "=================================================================="
