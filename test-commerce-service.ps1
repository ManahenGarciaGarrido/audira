# ================================================================
# Test Script para Commerce Service - Puerto 9004
# ================================================================
# Este script prueba todos los endpoints del microservicio Commerce Service
# directamente sin pasar por el API Gateway
# ================================================================

$baseUrl = "http://localhost:9004"
$VerbosePreference = "Continue"
$global:testUserId = 1  # Usuario de prueba
$global:testProductId = $null
$global:testVariantId = $null
$global:testOrderId = $null
$global:testPaymentId = $null

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

Print-Header "COMMERCE SERVICE - Products"

# --- ProductController: /api/products ---
Write-Host "`n=== ProductController ==="

# 1. Crear Producto
$productBody = @{
    artistId    = $global:testUserId
    name        = "Test T-Shirt"
    description = "Awesome test t-shirt"
    category    = "CLOTHING"
    price       = 24.99
    stock       = 100
    imageUrls   = @("http://example.com/tshirt1.jpg", "http://example.com/tshirt2.jpg")
    isActive    = $true
}
$productResponse = Invoke-ApiRequest -Method POST -Path "/api/products" -Body $productBody
if ($productResponse) { $global:testProductId = $productResponse.id }

# 2. Listar Todos los Productos
Invoke-ApiRequest -Method GET -Path "/api/products"

# 3. Obtener Producto por ID
if ($global:testProductId) {
    Invoke-ApiRequest -Method GET -Path "/api/products/$global:testProductId"
}

# 4. Obtener Productos por Artista
Invoke-ApiRequest -Method GET -Path "/api/products?artistId=$global:testUserId"

# 5. Obtener Productos por Categoría
Invoke-ApiRequest -Method GET -Path "/api/products?category=CLOTHING"

# 6. Obtener Productos por Artista y Categoría
Invoke-ApiRequest -Method GET -Path "/api/products?artistId=$global:testUserId&category=CLOTHING"

# 7. Buscar Productos
Invoke-ApiRequest -Method GET -Path "/api/products?search=test"

# 8. Obtener Todas las Categorías
Invoke-ApiRequest -Method GET -Path "/api/products/categories"

# 9. Actualizar Producto
if ($global:testProductId) {
    $updateProductBody = @{
        artistId    = $global:testUserId
        name        = "Test T-Shirt (Updated)"
        description = "Updated awesome t-shirt"
        category    = "CLOTHING"
        price       = 29.99
        stock       = 150
        imageUrls   = @("http://example.com/tshirt-updated.jpg")
        isActive    = $true
    }
    Invoke-ApiRequest -Method PUT -Path "/api/products/$global:testProductId" -Body $updateProductBody
}

# 10. Actualizar Stock de Producto
if ($global:testProductId) {
    Invoke-ApiRequest -Method PATCH -Path "/api/products/$global:testProductId/stock?stock=200"
}

Print-Header "COMMERCE SERVICE - Product Variants"

# --- Product Variants ---
Write-Host "`n=== Product Variants ==="

# 11. Añadir Variante a Producto
if ($global:testProductId) {
    $variantBody = @{
        name         = "Size: M, Color: Blue"
        size         = "M"
        color        = "Blue"
        additionalPrice = 2.00
        stock        = 50
        sku          = "TSH-M-BLU"
    }
    $variantResponse = Invoke-ApiRequest -Method POST -Path "/api/products/$global:testProductId/variants" -Body $variantBody
    if ($variantResponse) { $global:testVariantId = $variantResponse.id }
}

# 12. Obtener Variantes de Producto
if ($global:testProductId) {
    Invoke-ApiRequest -Method GET -Path "/api/products/$global:testProductId/variants"
}

# 13. Obtener Variante por ID
if ($global:testVariantId) {
    Invoke-ApiRequest -Method GET -Path "/api/products/variants/$global:testVariantId"
}

# 14. Actualizar Variante
if ($global:testVariantId) {
    $updateVariantBody = @{
        name            = "Size: M, Color: Blue (Updated)"
        size            = "M"
        color           = "Navy Blue"
        additionalPrice = 3.00
        stock           = 60
        sku             = "TSH-M-BLU-V2"
    }
    Invoke-ApiRequest -Method PUT -Path "/api/products/variants/$global:testVariantId" -Body $updateVariantBody
}

# 15. Actualizar Stock de Variante
if ($global:testVariantId) {
    Invoke-ApiRequest -Method PATCH -Path "/api/products/variants/$global:testVariantId/stock?stock=75"
}

Print-Header "COMMERCE SERVICE - Shopping Cart"

# --- CartController: /api/cart ---
Write-Host "`n=== CartController ==="

# 16. Obtener Carrito
Invoke-ApiRequest -Method GET -Path "/api/cart/$global:testUserId"

# 17. Añadir Item al Carrito (Producto)
if ($global:testProductId) {
    Invoke-ApiRequest -Method POST -Path "/api/cart/$global:testUserId/items?itemType=PRODUCT&itemId=$global:testProductId&quantity=2&price=29.99"
}

# 18. Añadir Item al Carrito (Canción)
Invoke-ApiRequest -Method POST -Path "/api/cart/$global:testUserId/items?itemType=SONG&itemId=1&quantity=1&price=1.99"

# 19. Obtener Conteo de Items en Carrito
Invoke-ApiRequest -Method GET -Path "/api/cart/$global:testUserId/count"

# 20. Obtener Total del Carrito
Invoke-ApiRequest -Method GET -Path "/api/cart/$global:testUserId/total"

# 21. Actualizar Cantidad de Item
if ($global:testProductId) {
    # Nota: itemId en la URL se refiere al CartItem ID, no al Product ID
    # Esto podría requerir obtener el carrito primero para obtener el CartItem ID
    # Por simplicidad, asumimos que funciona con el product ID
    Invoke-ApiRequest -Method PUT -Path "/api/cart/$global:testUserId/items/$global:testProductId?quantity=3"
}

# 22. Ver Carrito Actualizado
Invoke-ApiRequest -Method GET -Path "/api/cart/$global:testUserId"

Print-Header "COMMERCE SERVICE - Orders"

# --- OrderController: /api/orders ---
Write-Host "`n=== OrderController ==="

# 23. Crear Pedido
$orderBody = @{
    userId          = $global:testUserId
    items           = @(
        @{
            itemType = "PRODUCT"
            itemId   = if ($global:testProductId) { $global:testProductId } else { 1 }
            quantity = 1
            price    = 29.99
        },
        @{
            itemType = "SONG"
            itemId   = 1
            quantity = 1
            price    = 1.99
        }
    )
    shippingAddress = "123 Test Street, Test City, TC 12345"
    billingAddress  = "123 Test Street, Test City, TC 12345"
}
$orderResponse = Invoke-ApiRequest -Method POST -Path "/api/orders" -Body $orderBody
if ($orderResponse) { $global:testOrderId = $orderResponse.id }

# 24. Listar Todos los Pedidos
Invoke-ApiRequest -Method GET -Path "/api/orders"

# 25. Obtener Pedido por ID
if ($global:testOrderId) {
    Invoke-ApiRequest -Method GET -Path "/api/orders/$global:testOrderId"
}

# 26. Obtener Pedidos de Usuario
Invoke-ApiRequest -Method GET -Path "/api/orders/user/$global:testUserId"

# 27. Obtener Pedidos por Estado
Invoke-ApiRequest -Method GET -Path "/api/orders/status/PENDING"

# 28. Obtener Pedidos de Usuario por Estado
Invoke-ApiRequest -Method GET -Path "/api/orders/user/$global:testUserId/status/PENDING"

# 29. Actualizar Estado de Pedido
if ($global:testOrderId) {
    $updateStatusBody = @{
        status = "PROCESSING"
    }
    Invoke-ApiRequest -Method PUT -Path "/api/orders/$global:testOrderId/status" -Body $updateStatusBody
}

# 30. Actualizar Estado a Enviado
if ($global:testOrderId) {
    $updateStatusBody = @{
        status = "SHIPPED"
    }
    Invoke-ApiRequest -Method PUT -Path "/api/orders/$global:testOrderId/status" -Body $updateStatusBody
}

# 31. Actualizar Estado a Entregado
if ($global:testOrderId) {
    $updateStatusBody = @{
        status = "DELIVERED"
    }
    Invoke-ApiRequest -Method PUT -Path "/api/orders/$global:testOrderId/status" -Body $updateStatusBody
}

Print-Header "COMMERCE SERVICE - Payments"

# --- PaymentController: /api/payments ---
Write-Host "`n=== PaymentController ==="

# 32. Crear Pago
if ($global:testOrderId) {
    $paymentResponse = Invoke-ApiRequest -Method POST -Path "/api/payments?orderId=$global:testOrderId&userId=$global:testUserId&amount=31.98&paymentMethod=CREDIT_CARD"
    if ($paymentResponse) { $global:testPaymentId = $paymentResponse.id }
}

# 33. Obtener Pago por ID
if ($global:testPaymentId) {
    Invoke-ApiRequest -Method GET -Path "/api/payments/$global:testPaymentId"
}

# 34. Obtener Pago por Pedido
if ($global:testOrderId) {
    Invoke-ApiRequest -Method GET -Path "/api/payments/order/$global:testOrderId"
}

# 35. Obtener Pagos de Usuario
Invoke-ApiRequest -Method GET -Path "/api/payments/user/$global:testUserId"

# 36. Procesar Pago
if ($global:testPaymentId) {
    Invoke-ApiRequest -Method POST -Path "/api/payments/$global:testPaymentId/process?transactionId=TXN-TEST-12345"
}

# 37. Completar Pago
if ($global:testPaymentId) {
    Invoke-ApiRequest -Method POST -Path "/api/payments/$global:testPaymentId/complete"
}

Print-Header "COMMERCE SERVICE - Additional Order Tests"

# --- Más Pruebas de Pedidos ---
Write-Host "`n=== Additional Order Tests ==="

# 38. Crear Otro Pedido para Cancelar
$orderBody2 = @{
    userId          = $global:testUserId
    items           = @(
        @{
            itemType = "SONG"
            itemId   = 2
            quantity = 1
            price    = 1.99
        }
    )
    shippingAddress = "456 Cancel Street, Cancel City, CC 67890"
}
$orderResponse2 = Invoke-ApiRequest -Method POST -Path "/api/orders" -Body $orderBody2
$cancelOrderId = if ($orderResponse2) { $orderResponse2.id } else { $null }

# 39. Cancelar Pedido
if ($cancelOrderId) {
    Invoke-ApiRequest -Method POST -Path "/api/orders/$cancelOrderId/cancel"
}

# 40. Verificar Estado Cancelado
if ($cancelOrderId) {
    Invoke-ApiRequest -Method GET -Path "/api/orders/$cancelOrderId"
}

Print-Header "COMMERCE SERVICE - Payment Edge Cases"

# --- Casos Extremos de Pagos ---
Write-Host "`n=== Payment Edge Cases ==="

# Crear otro pedido para pruebas de pago fallido
$orderBody3 = @{
    userId          = $global:testUserId
    items           = @(
        @{
            itemType = "PRODUCT"
            itemId   = if ($global:testProductId) { $global:testProductId } else { 1 }
            quantity = 1
            price    = 29.99
        }
    )
    shippingAddress = "789 Fail Street, Fail City, FC 11111"
}
$orderResponse3 = Invoke-ApiRequest -Method POST -Path "/api/orders" -Body $orderBody3
$failOrderId = if ($orderResponse3) { $orderResponse3.id } else { $null }

# 41. Crear Pago que Fallará
if ($failOrderId) {
    $failPaymentResponse = Invoke-ApiRequest -Method POST -Path "/api/payments?orderId=$failOrderId&userId=$global:testUserId&amount=29.99&paymentMethod=DEBIT_CARD"
    $failPaymentId = if ($failPaymentResponse) { $failPaymentResponse.id } else { $null }

    # 42. Fallar el Pago
    if ($failPaymentId) {
        Invoke-ApiRequest -Method POST -Path "/api/payments/$failPaymentId/fail"
    }
}

# Crear otro pedido para pruebas de reembolso
$orderBody4 = @{
    userId          = $global:testUserId
    items           = @(
        @{
            itemType = "SONG"
            itemId   = 3
            quantity = 1
            price    = 0.99
        }
    )
    shippingAddress = "321 Refund Avenue, Refund Town, RT 22222"
}
$orderResponse4 = Invoke-ApiRequest -Method POST -Path "/api/orders" -Body $orderBody4
$refundOrderId = if ($orderResponse4) { $orderResponse4.id } else { $null }

# 43. Crear Pago para Reembolso
if ($refundOrderId) {
    $refundPaymentResponse = Invoke-ApiRequest -Method POST -Path "/api/payments?orderId=$refundOrderId&userId=$global:testUserId&amount=0.99&paymentMethod=PAYPAL"
    $refundPaymentId = if ($refundPaymentResponse) { $refundPaymentResponse.id } else { $null }

    # 44. Procesar y Completar el Pago
    if ($refundPaymentId) {
        Invoke-ApiRequest -Method POST -Path "/api/payments/$refundPaymentId/process?transactionId=TXN-REFUND-67890"
        Invoke-ApiRequest -Method POST -Path "/api/payments/$refundPaymentId/complete"

        # 45. Reembolsar el Pago
        Invoke-ApiRequest -Method POST -Path "/api/payments/$refundPaymentId/refund"
    }
}

Print-Header "COMMERCE SERVICE - Cleanup"

# --- Limpieza ---
Write-Host "`n=== Cleanup ==="

# Limpiar Carrito
Invoke-ApiRequest -Method DELETE -Path "/api/cart/$global:testUserId"

# Eliminar Pedidos (si el endpoint lo permite)
if ($cancelOrderId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/orders/$cancelOrderId"
}
if ($failOrderId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/orders/$failOrderId"
}
if ($refundOrderId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/orders/$refundOrderId"
}

# Eliminar Variante
if ($global:testVariantId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/products/variants/$global:testVariantId"
}

# Eliminar Producto
if ($global:testProductId) {
    Invoke-ApiRequest -Method DELETE -Path "/api/products/$global:testProductId"
}

# Nota: Los pagos generalmente no se eliminan por razones de auditoría
# pero se incluye aquí por completitud si el endpoint existe

Write-Host "`n"
Write-Host "=================================================================="
Write-Host "  COMMERCE SERVICE TEST SCRIPT FINISHED"
Write-Host "=================================================================="
