# ================================================================
# Test Script para Community Service - Puerto 9001
# ================================================================
# Este script prueba todos los endpoints del microservicio Community Service
# directamente sin pasar por el API Gateway
# ================================================================

$baseUrl = "http://localhost:9001"
$VerbosePreference = "Continue"
$global:jwtToken = $null
$global:testUserId = $null

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
        [object]$Body = $null,
        [switch]$RequiresJwt,
        [switch]$UseQueryParams
    )

    $uri = "$baseUrl$Path"
    $headers = @{}
    $contentType = "application/json"

    if ($RequiresJwt.IsPresent -and $global:jwtToken) {
        $headers.Add("Authorization", "Bearer $($global:jwtToken)")
        Write-Verbose "Using JWT Token for request."
    }

    $params = @{
        Uri         = $uri
        Method      = $Method
        Headers     = $headers
        ContentType = $contentType
        Verbose     = $true
        ErrorAction = 'SilentlyContinue'
    }

    if ($Body -and !$UseQueryParams.IsPresent) {
        $params.Add("Body", ($Body | ConvertTo-Json -Depth 5))
    }

    Write-Host "`n[$Method] $Path"
    if($Body -and !$UseQueryParams.IsPresent) {
        Write-Host "Body: $($params.Body)"
    }

    try {
        $response = Invoke-RestMethod @params
        Write-Host "Response Status: OK"
        Write-Host "Response Body:"
        Write-Output ($response | ConvertTo-Json -Depth 5)

        if ($response -is [pscustomobject] -and $response.PSObject.Properties.Name -contains 'token') {
            $global:jwtToken = $response.token
            Write-Host "JWT Token Captured!"
        }

        if ($response -is [pscustomobject] -and $response.PSObject.Properties.Name -contains 'user') {
            if ($response.user.PSObject.Properties.Name -contains 'id') {
                $global:testUserId = $response.user.id
                Write-Host "Test User ID Captured: $global:testUserId"
            }
        }

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

Print-Header "COMMUNITY SERVICE - Authentication & Users"

# --- AuthController: /api/users/auth ---
Write-Host "`n=== AuthController ==="

# 1. Registrar Usuario
$registerBody = @{
    email     = "testuser@community.com"
    username  = "testuser_community"
    password  = "Password123!"
    firstName = "Community"
    lastName  = "Tester"
    role      = "USER"
}
$registerResponse = Invoke-ApiRequest -Method POST -Path "/api/users/auth/register" -Body $registerBody

# 2. Login
$loginBody = @{
    emailOrUsername = "testuser@community.com"
    password        = "Password123!"
}
$loginResponse = Invoke-ApiRequest -Method POST -Path "/api/users/auth/login" -Body $loginBody

# --- UserController: /api/users ---
Write-Host "`n=== UserController ==="

# 3. Ver Perfil Actual
Invoke-ApiRequest -Method GET -Path "/api/users/profile" -RequiresJwt

# 4. Actualizar Perfil
$updateProfileBody = @{
    firstName = "Community-Updated"
    lastName  = "Tester-Updated"
    bio       = "Community service tester bio"
}
Invoke-ApiRequest -Method PUT -Path "/api/users/profile" -Body $updateProfileBody -RequiresJwt

# 5. Ver Perfil por ID
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/users/$global:testUserId" -RequiresJwt
}

# 6. Listar Todos los Usuarios
Invoke-ApiRequest -Method GET -Path "/api/users" -RequiresJwt

Print-Header "COMMUNITY SERVICE - Ratings & Comments"

# --- RatingController: /api/ratings ---
Write-Host "`n=== RatingController ==="

$ratingId = $null

# 7. Crear Valoración
if ($global:testUserId) {
    $response = Invoke-ApiRequest -Method POST -Path "/api/ratings?userId=$global:testUserId&entityType=SONG&entityId=1&rating=5" -RequiresJwt
    if ($response) { $ratingId = $response.id }
}

# 8. Obtener Valoraciones de Usuario
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/ratings/user/$global:testUserId" -RequiresJwt
}

# 9. Obtener Valoraciones de Entidad
Invoke-ApiRequest -Method GET -Path "/api/ratings/entity/SONG/1"

# 10. Obtener Estadísticas de Valoración
Invoke-ApiRequest -Method GET -Path "/api/ratings/entity/SONG/1/average"

# 11. Obtener Valoración de Usuario para Entidad
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/ratings/user/$global:testUserId/entity/SONG/1"
}

# --- CommentController: /api/comments ---
Write-Host "`n=== CommentController ==="

$commentId = $null

# 12. Crear Comentario
if ($global:testUserId) {
    $response = Invoke-ApiRequest -Method POST -Path "/api/comments?userId=$global:testUserId&entityType=SONG&entityId=1&content=Great song!" -RequiresJwt
    if ($response) { $commentId = $response.id }
}

# 13. Obtener Comentarios de Entidad
Invoke-ApiRequest -Method GET -Path "/api/comments/entity/SONG/1"

# 14. Obtener Comentarios de Usuario
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/comments/user/$global:testUserId"
}

# 15. Obtener Comentario por ID
if ($commentId) {
    Invoke-ApiRequest -Method GET -Path "/api/comments/$commentId"
}

# 16. Actualizar Comentario
if ($commentId) {
    Invoke-ApiRequest -Method PUT -Path "/api/comments/${commentId}?content=Updated comment!" -RequiresJwt
}

# 17. Crear Respuesta a Comentario
if ($global:testUserId -and $commentId) {
    Invoke-ApiRequest -Method POST -Path "/api/comments?userId=$global:testUserId&entityType=SONG&entityId=1&content=Reply to comment&parentCommentId=$commentId" -RequiresJwt
}

# 18. Obtener Respuestas de Comentario
if ($commentId) {
    Invoke-ApiRequest -Method GET -Path "/api/comments/$commentId/replies"
}

Print-Header "COMMUNITY SERVICE - Metrics"

# --- UserMetricsController: /api/metrics/users ---
Write-Host "`n=== UserMetricsController ==="

# 19. Obtener Métricas de Usuario
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/metrics/users/$global:testUserId"
}

# 20. Incrementar Reproducciones de Usuario
if ($global:testUserId) {
    Invoke-ApiRequest -Method POST -Path "/api/metrics/users/$global:testUserId/plays"
}

# 21. Añadir Tiempo de Escucha
if ($global:testUserId) {
    Invoke-ApiRequest -Method POST -Path "/api/metrics/users/$global:testUserId/listening-time?seconds=300"
}

# 22. Incrementar Seguidores
if ($global:testUserId) {
    Invoke-ApiRequest -Method POST -Path "/api/metrics/users/$global:testUserId/followers/increment"
}

# 23. Decrementar Seguidores
if ($global:testUserId) {
    Invoke-ApiRequest -Method POST -Path "/api/metrics/users/$global:testUserId/followers/decrement"
}

# 24. Incrementar Siguiendo
if ($global:testUserId) {
    Invoke-ApiRequest -Method POST -Path "/api/metrics/users/$global:testUserId/following/increment"
}

# 25. Decrementar Siguiendo
if ($global:testUserId) {
    Invoke-ApiRequest -Method POST -Path "/api/metrics/users/$global:testUserId/following/decrement"
}

# 26. Incrementar Compras
if ($global:testUserId) {
    Invoke-ApiRequest -Method POST -Path "/api/metrics/users/$global:testUserId/purchases"
}

# --- ArtistMetricsController: /api/metrics/artists ---
Write-Host "`n=== ArtistMetricsController ==="

# 27. Obtener Métricas de Artista
Invoke-ApiRequest -Method GET -Path "/api/metrics/artists/1"

# 28. Incrementar Reproducciones de Artista
Invoke-ApiRequest -Method POST -Path "/api/metrics/artists/1/plays"

# 29. Incrementar Oyentes de Artista
Invoke-ApiRequest -Method POST -Path "/api/metrics/artists/1/listeners"

# 30. Incrementar Seguidores de Artista
Invoke-ApiRequest -Method POST -Path "/api/metrics/artists/1/followers/increment"

# 31. Decrementar Seguidores de Artista
Invoke-ApiRequest -Method POST -Path "/api/metrics/artists/1/followers/decrement"

# 32. Añadir Venta de Artista
Invoke-ApiRequest -Method POST -Path "/api/metrics/artists/1/sales?amount=9.99"

# --- SongMetricsController: /api/metrics/songs ---
Write-Host "`n=== SongMetricsController ==="

# 33. Obtener Métricas de Canción
Invoke-ApiRequest -Method GET -Path "/api/metrics/songs/1"

# 34. Incrementar Reproducciones de Canción
Invoke-ApiRequest -Method POST -Path "/api/metrics/songs/1/plays"

# 35. Incrementar Oyentes de Canción
Invoke-ApiRequest -Method POST -Path "/api/metrics/songs/1/listeners"

# 36. Incrementar Likes
Invoke-ApiRequest -Method POST -Path "/api/metrics/songs/1/likes"

# 37. Decrementar Likes
Invoke-ApiRequest -Method DELETE -Path "/api/metrics/songs/1/likes"

# 38. Incrementar Compartidos
Invoke-ApiRequest -Method POST -Path "/api/metrics/songs/1/shares"

# 39. Incrementar Descargas
Invoke-ApiRequest -Method POST -Path "/api/metrics/songs/1/downloads"

# --- GlobalMetricsController: /api/metrics/global ---
Write-Host "`n=== GlobalMetricsController ==="

# 40. Obtener Métricas Globales
$globalMetrics = Invoke-ApiRequest -Method GET -Path "/api/metrics/global"

# 41. Actualizar Métricas Globales
if ($globalMetrics) {
    Invoke-ApiRequest -Method PUT -Path "/api/metrics/global" -Body $globalMetrics
}

Print-Header "COMMUNITY SERVICE - Notifications"

# --- NotificationController: /api/notifications ---
Write-Host "`n=== NotificationController ==="

$notificationId = $null

# 42. Crear Notificación
if ($global:testUserId) {
    $notificationBody = @{
        userId  = $global:testUserId
        title   = "Test Notification"
        message = "This is a test notification"
        type    = "INFO"
    }
    $response = Invoke-ApiRequest -Method POST -Path "/api/notifications" -Body $notificationBody
    if ($response) { $notificationId = $response.id }
}

# 43. Listar Todas las Notificaciones
Invoke-ApiRequest -Method GET -Path "/api/notifications"

# 44. Obtener Notificaciones de Usuario
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/notifications/user/$global:testUserId"
}

# 45. Obtener Notificaciones No Leídas
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/notifications/user/$global:testUserId/unread"
}

# 46. Obtener Conteo de No Leídas
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/notifications/user/$global:testUserId/unread/count"
}

# 47. Obtener Notificaciones por Tipo
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/notifications/user/$global:testUserId/type/INFO"
}

# 48. Obtener Notificación por ID
if ($notificationId) {
    Invoke-ApiRequest -Method GET -Path "/api/notifications/$notificationId"
}

# 49. Marcar como Leída
if ($notificationId) {
    Invoke-ApiRequest -Method PUT -Path "/api/notifications/$notificationId/read"
}

# 50. Marcar Todas como Leídas
if ($global:testUserId) {
    Invoke-ApiRequest -Method PUT -Path "/api/notifications/user/$global:testUserId/read-all"
}

Print-Header "COMMUNITY SERVICE - FAQs"

# --- FAQController: /api/faqs ---
Write-Host "`n=== FAQController ==="

$faqId = $null

# 51. Crear FAQ
$faqBody = @{
    question = "How to use Audira?"
    answer   = "Just enjoy the music!"
    category = "GENERAL"
    isActive = $true
}
$response = Invoke-ApiRequest -Method POST -Path "/api/faqs" -Body $faqBody
if ($response) { $faqId = $response.id }

# 52. Listar Todas las FAQs
Invoke-ApiRequest -Method GET -Path "/api/faqs"

# 53. Listar FAQs Activas
Invoke-ApiRequest -Method GET -Path "/api/faqs/active"

# 54. Obtener FAQs por Categoría
Invoke-ApiRequest -Method GET -Path "/api/faqs/category/GENERAL"

# 55. Obtener FAQ por ID
if ($faqId) {
    Invoke-ApiRequest -Method GET -Path "/api/faqs/$faqId"
}

# 56. Actualizar FAQ
if ($faqId) {
    $updateFaqBody = @{
        question = "How to use Audira? (Updated)"
        answer   = "Just enjoy the music! (Updated)"
        category = "GENERAL"
        isActive = $true
    }
    Invoke-ApiRequest -Method PUT -Path "/api/faqs/$faqId" -Body $updateFaqBody
}

# 57. Alternar Estado Activo
if ($faqId) {
    Invoke-ApiRequest -Method PUT -Path "/api/faqs/$faqId/toggle-active"
}

# 58. Incrementar Vistas
if ($faqId) {
    Invoke-ApiRequest -Method POST -Path "/api/faqs/$faqId/view"
}

# 59. Marcar como Útil
if ($faqId) {
    Invoke-ApiRequest -Method POST -Path "/api/faqs/$faqId/helpful"
}

# 60. Marcar como No Útil
if ($faqId) {
    Invoke-ApiRequest -Method POST -Path "/api/faqs/$faqId/not-helpful"
}

Print-Header "COMMUNITY SERVICE - Contact Messages"

# --- ContactController: /api/contact ---
Write-Host "`n=== ContactController ==="

$contactId = $null

# 61. Crear Mensaje de Contacto
if ($global:testUserId) {
    $response = Invoke-ApiRequest -Method POST -Path "/api/contact?userId=$global:testUserId&name=Test User&email=test@example.com&subject=Test Subject&message=Test message&messageType=GENERAL"
    if ($response) { $contactId = $response.id }
}

# 62. Listar Todos los Mensajes
Invoke-ApiRequest -Method GET -Path "/api/contact"

# 63. Obtener Mensajes de Usuario
if ($global:testUserId) {
    Invoke-ApiRequest -Method GET -Path "/api/contact/user/$global:testUserId"
}

# 64. Obtener Mensajes por Estado
Invoke-ApiRequest -Method GET -Path "/api/contact/status/PENDING"

# 65. Obtener Mensaje por ID
if ($contactId) {
    Invoke-ApiRequest -Method GET -Path "/api/contact/$contactId"
}

# 66. Actualizar Estado de Mensaje
if ($contactId) {
    Invoke-ApiRequest -Method PUT -Path "/api/contact/$contactId/status?status=IN_PROGRESS"
}

# 67. Responder a Mensaje
if ($contactId) {
    Invoke-ApiRequest -Method POST -Path "/api/contact/$contactId/respond?response=Thank you for contacting us!"
}

Print-Header "COMMUNITY SERVICE - Cleanup"

# --- Limpieza ---
Write-Host "`n=== Cleanup ==="

# Eliminar Comentario
if ($commentId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/comments/$commentId" -RequiresJwt
}

# Eliminar Valoración
if ($ratingId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/ratings/$ratingId" -RequiresJwt
}

# Eliminar Notificaciones de Usuario
if ($global:testUserId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/notifications/user/$global:testUserId"
}

# Eliminar FAQ
if ($faqId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/faqs/$faqId"
}

# Eliminar Usuario (si es posible)
# if ($global:testUserId) {
#     Invoke-ApiRequest -Method DELETE -Path "/api/users/$global:testUserId" -RequiresJwt
# }

Write-Host "`n"
Write-Host "=================================================================="
Write-Host "  COMMUNITY SERVICE TEST SCRIPT FINISHED"
Write-Host "=================================================================="
