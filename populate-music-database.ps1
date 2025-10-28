# ================================================================
# Script para Poblar la Base de Datos con Canciones y Álbumes Reales
# ================================================================
# Este script crea géneros, álbumes y canciones con datos reales
# y referencias correctas entre ellos
# ================================================================

$baseUrl = "http://localhost:9002"
$VerbosePreference = "Continue"

# Variables globales para IDs
$global:genreIds = @{}
$global:albumIds = @{}
$global:songIds = @{}

# --- Funciones de Ayuda ---
function Print-Header($title) {
    Write-Host "`n=================================================================="
    Write-Host "  $title"
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
        Verbose     = $false
        ErrorAction = 'SilentlyContinue'
    }

    if ($Body) {
        $params.Add("Body", ($Body | ConvertTo-Json -Depth 5))
    }

    Write-Host "[$Method] $Path" -ForegroundColor Cyan

    try {
        $response = Invoke-RestMethod @params
        Write-Host "✓ Success - Created ID: $($response.id)" -ForegroundColor Green
        return $response
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "✗ Failed - Status: $statusCode" -ForegroundColor Red
        return $null
    }
}

# ================================================================
# CREAR GÉNEROS
# ================================================================
Print-Header "Creando Géneros"

$genres = @(
    @{ name = "Rock"; description = "Rock music genre"; imageUrl = "https://i.scdn.co/image/ab67706f00000002e89c6e36ecbf5a967a96c183" },
    @{ name = "Pop"; description = "Pop music genre"; imageUrl = "https://i.scdn.co/image/ab67706f000000029bb6af539d072de6c0ed8903" },
    @{ name = "Hip Hop"; description = "Hip Hop and Rap music"; imageUrl = "https://i.scdn.co/image/ab67706f00000002503f47c87ef9cf8ee0a01cd4" },
    @{ name = "RnB"; description = "Rhythm and Blues"; imageUrl = "https://i.scdn.co/image/ab67706f00000002f88c27f154471c5fa1ed3c8e" },
    @{ name = "Electronic"; description = "Electronic and Dance music"; imageUrl = "https://i.scdn.co/image/ab67706f00000002a1f2b3b3f3e3f3e3f3e3f3e3" },
    @{ name = "Jazz"; description = "Jazz music genre"; imageUrl = "https://i.scdn.co/image/ab67706f00000002f88c27f154471c5fa1ed3c8e" }
)

foreach ($genre in $genres) {
    $response = Invoke-ApiRequest -Method POST -Path "/api/genres" -Body $genre
    if ($response) {
        $global:genreIds[$genre.name] = $response.id
    }
}

# ================================================================
# CREAR ÁLBUMES
# ================================================================
Print-Header "Creando Álbumes"

$albums = @(
    @{
        title = "Abbey Road"
        artistId = 1
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273dc30583ba717007b00cceb25"
        description = "Undécimo álbum de estudio de The Beatles, considerado una obra maestra"
        releaseDate = "1969-09-26"
        price = 14.99
        genreIds = @($global:genreIds["Rock"])
        key = "AbbeyRoad"
    },
    @{
        title = "Thriller"
        artistId = 2
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2734121faee8df82c526cbab2be"
        description = "Sexto álbum de Michael Jackson, el álbum más vendido de todos los tiempos"
        releaseDate = "1982-11-30"
        price = 12.99
        genreIds = @($global:genreIds["Pop"])
        key = "Thriller"
    },
    @{
        title = "The Dark Side of the Moon"
        artistId = 3
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273ea7caaff71dea1051d49b2fe"
        description = "Octavo álbum de Pink Floyd, obra maestra del rock progresivo"
        releaseDate = "1973-03-01"
        price = 13.99
        genreIds = @($global:genreIds["Rock"])
        key = "DarkSide"
    },
    @{
        title = "Back to Black"
        artistId = 4
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2739e2f95ae77cf436017ada9cb"
        description = "Segundo y último álbum de estudio de Amy Winehouse"
        releaseDate = "2006-10-27"
        price = 11.99
        genreIds = @($global:genreIds["RnB"], $global:genreIds["Jazz"])
        key = "BackToBlack"
    },
    @{
        title = "Random Access Memories"
        artistId = 5
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273de54f49c4f92ff5e71f8ec5b"
        description = "Cuarto álbum de estudio de Daft Punk"
        releaseDate = "2013-05-17"
        price = 12.99
        genreIds = @($global:genreIds["Electronic"])
        key = "RAM"
    },
    @{
        title = "good kid, m.A.A.d city"
        artistId = 6
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2738b5dcfdb0e9bbe61eecc6fc9"
        description = "Segundo álbum de estudio de Kendrick Lamar"
        releaseDate = "2012-10-22"
        price = 11.99
        genreIds = @($global:genreIds["Hip Hop"])
        key = "GKMC"
    }
)

foreach ($album in $albums) {
    $albumKey = $album.key
    $album.Remove("key")
    $response = Invoke-ApiRequest -Method POST -Path "/api/albums" -Body $album
    if ($response) {
        $global:albumIds[$albumKey] = $response.id
    }
}

# ================================================================
# CREAR CANCIONES
# ================================================================
Print-Header "Creando Canciones"

$songs = @(
    # Abbey Road
    @{
        title = "Come Together"
        artistId = 1
        albumId = $global:albumIds["AbbeyRoad"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273dc30583ba717007b00cceb25"
        description = "Canción de apertura de Abbey Road"
        price = 1.29
        duration = 259
        audioUrl = "https://example.com/come-together.mp3"
        trackNumber = 1
        genreIds = @($global:genreIds["Rock"])
    },
    @{
        title = "Here Comes the Sun"
        artistId = 1
        albumId = $global:albumIds["AbbeyRoad"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273dc30583ba717007b00cceb25"
        description = "Una de las canciones más populares de The Beatles, escrita por George Harrison"
        price = 1.29
        duration = 185
        audioUrl = "https://example.com/here-comes-the-sun.mp3"
        trackNumber = 7
        genreIds = @($global:genreIds["Rock"])
    },
    @{
        title = "Something"
        artistId = 1
        albumId = $global:albumIds["AbbeyRoad"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273dc30583ba717007b00cceb25"
        description = "Considerada una de las mejores canciones de amor jamás escritas"
        price = 1.29
        duration = 182
        audioUrl = "https://example.com/something.mp3"
        trackNumber = 2
        genreIds = @($global:genreIds["Rock"])
    },

    # Thriller
    @{
        title = "Thriller"
        artistId = 2
        albumId = $global:albumIds["Thriller"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2734121faee8df82c526cbab2be"
        description = "Canción icónica con el famoso video de zombies"
        price = 1.29
        duration = 357
        audioUrl = "https://example.com/thriller.mp3"
        trackNumber = 4
        genreIds = @($global:genreIds["Pop"])
    },
    @{
        title = "Billie Jean"
        artistId = 2
        albumId = $global:albumIds["Thriller"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2734121faee8df82c526cbab2be"
        description = "Uno de los mayores éxitos de Michael Jackson"
        price = 1.29
        duration = 294
        audioUrl = "https://example.com/billie-jean.mp3"
        trackNumber = 6
        genreIds = @($global:genreIds["Pop"])
    },
    @{
        title = "Beat It"
        artistId = 2
        albumId = $global:albumIds["Thriller"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2734121faee8df82c526cbab2be"
        description = "Canción con el legendario solo de guitarra de Eddie Van Halen"
        price = 1.29
        duration = 258
        audioUrl = "https://example.com/beat-it.mp3"
        trackNumber = 5
        genreIds = @($global:genreIds["Pop"], $global:genreIds["Rock"])
    },

    # Dark Side of the Moon
    @{
        title = "Time"
        artistId = 3
        albumId = $global:albumIds["DarkSide"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273ea7caaff71dea1051d49b2fe"
        description = "Canción sobre el paso del tiempo y el envejecimiento"
        price = 1.29
        duration = 413
        audioUrl = "https://example.com/time.mp3"
        trackNumber = 4
        genreIds = @($global:genreIds["Rock"])
    },
    @{
        title = "Money"
        artistId = 3
        albumId = $global:albumIds["DarkSide"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273ea7caaff71dea1051d49b2fe"
        description = "Crítica satírica al materialismo con su característico riff en 7/4"
        price = 1.29
        duration = 382
        audioUrl = "https://example.com/money.mp3"
        trackNumber = 6
        genreIds = @($global:genreIds["Rock"])
    },
    @{
        title = "Us and Them"
        artistId = 3
        albumId = $global:albumIds["DarkSide"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273ea7caaff71dea1051d49b2fe"
        description = "Reflexión sobre conflictos y división"
        price = 1.29
        duration = 462
        audioUrl = "https://example.com/us-and-them.mp3"
        trackNumber = 7
        genreIds = @($global:genreIds["Rock"])
    },

    # Back to Black
    @{
        title = "Rehab"
        artistId = 4
        albumId = $global:albumIds["BackToBlack"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2739e2f95ae77cf436017ada9cb"
        description = "El mayor éxito de Amy Winehouse"
        price = 1.29
        duration = 213
        audioUrl = "https://example.com/rehab.mp3"
        trackNumber = 1
        genreIds = @($global:genreIds["RnB"], $global:genreIds["Jazz"])
    },
    @{
        title = "Back to Black"
        artistId = 4
        albumId = $global:albumIds["BackToBlack"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2739e2f95ae77cf436017ada9cb"
        description = "Canción que da título al álbum"
        price = 1.29
        duration = 241
        audioUrl = "https://example.com/back-to-black.mp3"
        trackNumber = 4
        genreIds = @($global:genreIds["RnB"])
    },

    # Random Access Memories
    @{
        title = "Get Lucky"
        artistId = 5
        albumId = $global:albumIds["RAM"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273de54f49c4f92ff5e71f8ec5b"
        description = "Colaboración con Pharrell Williams y Nile Rodgers"
        price = 1.29
        duration = 368
        audioUrl = "https://example.com/get-lucky.mp3"
        trackNumber = 8
        genreIds = @($global:genreIds["Electronic"], $global:genreIds["Pop"])
    },
    @{
        title = "Instant Crush"
        artistId = 5
        albumId = $global:albumIds["RAM"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b273de54f49c4f92ff5e71f8ec5b"
        description = "Colaboración con Julian Casablancas de The Strokes"
        price = 1.29
        duration = 337
        audioUrl = "https://example.com/instant-crush.mp3"
        trackNumber = 5
        genreIds = @($global:genreIds["Electronic"])
    },

    # good kid, m.A.A.d city
    @{
        title = "Swimming Pools (Drank)"
        artistId = 6
        albumId = $global:albumIds["GKMC"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2738b5dcfdb0e9bbe61eecc6fc9"
        description = "Reflexión sobre el alcoholismo y la presión social"
        price = 1.29
        duration = 313
        audioUrl = "https://example.com/swimming-pools.mp3"
        trackNumber = 9
        genreIds = @($global:genreIds["Hip Hop"])
    },
    @{
        title = "m.A.A.d city"
        artistId = 6
        albumId = $global:albumIds["GKMC"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2738b5dcfdb0e9bbe61eecc6fc9"
        description = "Descripción de la violencia en las calles de Compton"
        price = 1.29
        duration = 331
        audioUrl = "https://example.com/maad-city.mp3"
        trackNumber = 10
        genreIds = @($global:genreIds["Hip Hop"])
    },
    @{
        title = "Poetic Justice"
        artistId = 6
        albumId = $global:albumIds["GKMC"]
        coverImageUrl = "https://i.scdn.co/image/ab67616d0000b2738b5dcfdb0e9bbe61eecc6fc9"
        description = "Colaboración con Drake"
        price = 1.29
        duration = 301
        audioUrl = "https://example.com/poetic-justice.mp3"
        trackNumber = 7
        genreIds = @($global:genreIds["Hip Hop"])
    }
)

$totalSongs = $songs.Count
$currentSong = 0

foreach ($song in $songs) {
    $currentSong++
    Write-Host "`n[$currentSong/$totalSongs] Creating: $($song.title) - Album ID: $($song.albumId)" -ForegroundColor Yellow
    $response = Invoke-ApiRequest -Method POST -Path "/api/songs" -Body $song
    if ($response) {
        $global:songIds[$song.title] = $response.id
    }
}

# ================================================================
# RESUMEN
# ================================================================
Print-Header "RESUMEN DE CREACIÓN"

Write-Host "`nGéneros creados: $($global:genreIds.Count)" -ForegroundColor Cyan
foreach ($genre in $global:genreIds.Keys) {
    Write-Host "  - $genre (ID: $($global:genreIds[$genre]))" -ForegroundColor Gray
}

Write-Host "`nÁlbumes creados: $($global:albumIds.Count)" -ForegroundColor Cyan
foreach ($album in $global:albumIds.Keys) {
    Write-Host "  - $album (ID: $($global:albumIds[$album]))" -ForegroundColor Gray
}

Write-Host "`nCanciones creadas: $($global:songIds.Count)" -ForegroundColor Cyan

Write-Host "`n=================================================================="
Write-Host "  ✓ Base de datos poblada exitosamente"
Write-Host "=================================================================="
Write-Host ""
