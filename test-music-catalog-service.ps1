# ================================================================
# Test Script para Music Catalog Service - Puerto 9002
# ================================================================
# Este script prueba todos los endpoints del microservicio Music Catalog Service
# directamente sin pasar por el API Gateway
# ================================================================

$baseUrl = "http://localhost:9002"
$VerbosePreference = "Continue"
$global:testGenreId = $null
$global:testAlbumId = $null
$global:testSongId = $null
$global:testCollaboratorId = $null

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

Print-Header "MUSIC CATALOG SERVICE - Genres"

# --- GenreController: /api/genres ---
Write-Host "`n=== GenreController ==="

# 1. Crear Género
$genreBody = @{
    name        = "Test Rock"
    description = "Test rock genre for music catalog"
    imageUrl    = "http://example.com/rock.jpg"
}
$genreResponse = Invoke-ApiRequest -Method POST -Path "/api/genres" -Body $genreBody
if ($genreResponse) { $global:testGenreId = $genreResponse.id }

# 2. Listar Todos los Géneros
Invoke-ApiRequest -Method GET -Path "/api/genres"

# 3. Obtener Género por ID
if ($global:testGenreId) {
    Invoke-ApiRequest -Method GET -Path "/api/genres/$global:testGenreId"
}

# 4. Actualizar Género
if ($global:testGenreId) {
    $updateGenreBody = @{
        name        = "Test Rock (Updated)"
        description = "Updated description"
        imageUrl    = "http://example.com/rock-updated.jpg"
    }
    Invoke-ApiRequest -Method PUT -Path "/api/genres/$global:testGenreId" -Body $updateGenreBody
}

Print-Header "MUSIC CATALOG SERVICE - Albums"

# --- AlbumController: /api/albums ---
Write-Host "`n=== AlbumController ==="

# 5. Crear Álbum
$albumBody = @{
    title       = "Test Album"
    artistId    = 1
    genreIds    = @(1)
    releaseDate = "2025-01-01"
    coverUrl    = "http://example.com/album-cover.jpg"
    description = "Test album description"
}
if ($global:testGenreId) {
    $albumBody.genreIds = @($global:testGenreId)
}
$albumResponse = Invoke-ApiRequest -Method POST -Path "/api/albums" -Body $albumBody
if ($albumResponse) { $global:testAlbumId = $albumResponse.id }

# 6. Listar Todos los Álbumes
Invoke-ApiRequest -Method GET -Path "/api/albums"

# 7. Obtener Álbum por ID
if ($global:testAlbumId) {
    Invoke-ApiRequest -Method GET -Path "/api/albums/$global:testAlbumId"
}

# 8. Obtener Álbumes por Artista
Invoke-ApiRequest -Method GET -Path "/api/albums/artist/1"

# 9. Obtener Álbumes por Género
if ($global:testGenreId) {
    Invoke-ApiRequest -Method GET -Path "/api/albums/genre/$global:testGenreId"
}

# 10. Actualizar Álbum
if ($global:testAlbumId) {
    $updateAlbumBody = @{
        title       = "Test Album (Updated)"
        artistId    = 1
        genreIds    = @(1)
        releaseDate = "2025-01-01"
        coverUrl    = "http://example.com/album-cover-updated.jpg"
        description = "Updated album description"
    }
    Invoke-ApiRequest -Method PUT -Path "/api/albums/$global:testAlbumId" -Body $updateAlbumBody
}

Print-Header "MUSIC CATALOG SERVICE - Songs"

# --- SongController: /api/songs ---
Write-Host "`n=== SongController ==="

# 11. Crear Canción
$songBody = @{
    title       = "Test Song"
    artistId    = 1
    albumId     = 1
    genreIds    = @(1)
    duration    = 210
    audioUrl    = "http://example.com/test-song.mp3"
    price       = 1.99
    trackNumber = 1
    lyrics      = "Test lyrics"
}
if ($global:testAlbumId) {
    $songBody.albumId = $global:testAlbumId
}
if ($global:testGenreId) {
    $songBody.genreIds = @($global:testGenreId)
}
$songResponse = Invoke-ApiRequest -Method POST -Path "/api/songs" -Body $songBody
if ($songResponse) { $global:testSongId = $songResponse.id }

# 12. Listar Todas las Canciones
Invoke-ApiRequest -Method GET -Path "/api/songs"

# 13. Obtener Canción por ID
if ($global:testSongId) {
    Invoke-ApiRequest -Method GET -Path "/api/songs/$global:testSongId"
}

# 14. Obtener Canciones por Artista
Invoke-ApiRequest -Method GET -Path "/api/songs/artist/1"

# 15. Obtener Canciones por Álbum
if ($global:testAlbumId) {
    Invoke-ApiRequest -Method GET -Path "/api/songs/album/$global:testAlbumId"
}

# 16. Obtener Canciones por Género
if ($global:testGenreId) {
    Invoke-ApiRequest -Method GET -Path "/api/songs/genre/$global:testGenreId"
}

# 17. Buscar Canciones
Invoke-ApiRequest -Method GET -Path "/api/songs/search?query=test"

# 18. Actualizar Canción
if ($global:testSongId) {
    $updateSongBody = @{
        title       = "Test Song (Updated)"
        artistId    = 1
        albumId     = 1
        genreIds    = @(1)
        duration    = 240
        audioUrl    = "http://example.com/test-song-updated.mp3"
        price       = 2.49
        trackNumber = 1
        lyrics      = "Updated test lyrics"
    }
    if ($global:testAlbumId) {
        $updateSongBody.albumId = $global:testAlbumId
    }
    if ($global:testGenreId) {
        $updateSongBody.genreIds = @($global:testGenreId)
    }
    Invoke-ApiRequest -Method PUT -Path "/api/songs/$global:testSongId" -Body $updateSongBody
}

Print-Header "MUSIC CATALOG SERVICE - Collaborations"

# --- CollaboratorController: /api/collaborations ---
Write-Host "`n=== CollaboratorController ==="

# 19. Añadir Colaborador
if ($global:testSongId) {
    $collaboratorBody = @{
        songId            = $global:testSongId
        artistId          = 2
        artistName        = "Featured Artist"
        collaborationType = "FEATURED_ARTIST"
        role              = "Vocals"
    }
    $collaboratorResponse = Invoke-ApiRequest -Method POST -Path "/api/collaborations" -Body $collaboratorBody
    if ($collaboratorResponse) { $global:testCollaboratorId = $collaboratorResponse.id }
}

# 20. Obtener Colaboradores por Canción
if ($global:testSongId) {
    Invoke-ApiRequest -Method GET -Path "/api/collaborations/song/$global:testSongId"
}

# 21. Obtener Colaboraciones por Artista
Invoke-ApiRequest -Method GET -Path "/api/collaborations/artist/1"

Print-Header "MUSIC CATALOG SERVICE - Discovery"

# --- DiscoveryController: /api/discovery ---
Write-Host "`n=== DiscoveryController ==="

# 22. Buscar Canciones
Invoke-ApiRequest -Method GET -Path "/api/discovery/search/songs?query=test"

# 23. Buscar Álbumes
Invoke-ApiRequest -Method GET -Path "/api/discovery/search/albums?query=test"

# 24. Canciones en Tendencia
Invoke-ApiRequest -Method GET -Path "/api/discovery/trending/songs"

# 25. Álbumes en Tendencia
Invoke-ApiRequest -Method GET -Path "/api/discovery/trending/albums"

# 26. Recomendaciones para Usuario
Invoke-ApiRequest -Method GET -Path "/api/discovery/recommendations?userId=1"

Print-Header "MUSIC CATALOG SERVICE - Cleanup"

# --- Limpieza ---
Write-Host "`n=== Cleanup ==="

# Eliminar Colaborador
if ($global:testCollaboratorId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/collaborations/$global:testCollaboratorId"
}

# Eliminar Canción
if ($global:testSongId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/songs/$global:testSongId"
}

# Eliminar Álbum
if ($global:testAlbumId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/albums/$global:testAlbumId"
}

# Eliminar Género
if ($global:testGenreId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/genres/$global:testGenreId"
}

Write-Host "`n"
Write-Host "=================================================================="
Write-Host "  MUSIC CATALOG SERVICE TEST SCRIPT FINISHED"
Write-Host "=================================================================="
