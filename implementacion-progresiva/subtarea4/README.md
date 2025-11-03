# SUBTAREA 4: CONFIRMACIÓN POR EMAIL SIMULADA (Eduardo)

## 🎯 Objetivo
Simular el proceso de confirmación de email con campo `isVerified` y endpoint de verificación.

## 📝 Cambios sobre Subtarea 3

Esta subtarea agrega:
- Campo `isVerified` para rastrear si el email está confirmado
- Campo `isActive` para habilitar/deshabilitar usuarios
- Endpoint para "verificar" el email
- Logs simulando el envío de email

## 📁 Archivos a modificar

### 1. User (agregar campos isActive e isVerified)
**Ruta:** `src/main/java/io/audira/community/model/User.java`

### 2. UserService (agregar método de verificación)
**Ruta:** `src/main/java/io/audira/community/service/UserService.java`

### 3. AuthController (agregar endpoint de verificación)
**Ruta:** `src/main/java/io/audira/community/controller/AuthController.java`

## 🧪 Cómo probar

### Paso 1: Registrar un usuario
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe",
    "role": "USER"
  }'
```

### Respuesta esperada:
```json
{
  "user": {
    "id": 1,
    "email": "test@example.com",
    "username": "testuser",
    "firstName": "John",
    "lastName": "Doe",
    "role": "USER",
    "isActive": true,
    "isVerified": false,
    ...
  },
  "message": "User registered successfully. Please check your email to verify your account."
}
```

### Ver en los logs:
```
📧 [SIMULADO] Email de verificación enviado a: test@example.com
📧 [SIMULADO] Link de verificación: http://localhost:3000/verify-email?userId=1
```

### Paso 2: Verificar el email
```bash
curl -X POST http://localhost:9001/api/auth/verify-email/1
```

### Respuesta esperada:
```json
{
  "user": {
    "id": 1,
    "email": "test@example.com",
    "username": "testuser",
    "firstName": "John",
    "lastName": "Doe",
    "role": "USER",
    "isActive": true,
    "isVerified": true,
    ...
  },
  "message": "Email verified successfully!"
}
```

### Paso 3: Intentar verificar de nuevo (debe fallar)
```bash
curl -X POST http://localhost:9001/api/auth/verify-email/1
```

### Respuesta esperada (error):
```json
{
  "error": "Email already verified"
}
```

## ✅ Checklist

- [ ] Agregar campo `isActive` al modelo User
- [ ] Agregar campo `isVerified` al modelo User
- [ ] Inicializar isActive=true e isVerified=false en @PrePersist
- [ ] Agregar logs simulando envío de email en registerUser()
- [ ] Crear método verifyEmail() en UserService
- [ ] Crear endpoint POST /api/auth/verify-email/{userId}
- [ ] Actualizar respuesta de registro con mensaje informativo
- [ ] Probar flujo completo: registro → verificación
- [ ] Verificar que no se puede verificar dos veces

## 🔄 Diferencias con Subtarea 3

### Modelo User - Antes (Subtarea 3):
```java
@Entity
public class User {
    private Long id;
    private String email;
    private UserRole role;
    // ...
}
```

### Modelo User - Después (Subtarea 4):
```java
@Entity
public class User {
    private Long id;
    private String email;
    private UserRole role;

    // NUEVOS CAMPOS
    private Boolean isActive;
    private Boolean isVerified;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.isActive == null) {
            this.isActive = true;
        }
        if (this.isVerified == null) {
            this.isVerified = false;
        }
    }
}
```

## 📧 Simulación de Email

En esta subtarea NO enviamos emails reales. En su lugar:
1. Mostramos un log en consola: `[SIMULADO] Email enviado a: ...`
2. Mostramos el link de verificación en los logs
3. El frontend puede mostrar un mensaje al usuario

### Para implementar envío real de emails en el futuro:
- Usar JavaMail API o SendGrid
- Crear servicio EmailService
- Generar tokens de verificación únicos
- Guardar token en base de datos
- Validar token en el endpoint de verificación

## 🎨 Frontend - Flujo de Verificación

### 1. Después del registro, mostrar mensaje:
```
"¡Registro exitoso!
Hemos enviado un email de verificación a tu correo.
Por favor verifica tu cuenta antes de continuar."
```

### 2. Página de verificación (opcional):
```
URL: /verify-email?userId=1
Botón: "Verificar mi email"
Llama a: POST /api/auth/verify-email/1
```

### 3. Mensaje de éxito:
```
"¡Email verificado correctamente!
Ya puedes iniciar sesión."
```

## 🔮 Mejoras futuras (no incluidas aquí)

- [ ] Generar tokens de verificación únicos (en lugar de usar userId)
- [ ] Establecer tiempo de expiración para los tokens (ej: 24 horas)
- [ ] Enviar emails reales con plantillas HTML
- [ ] Permitir reenviar email de verificación
- [ ] Bloquear ciertas funcionalidades si no está verificado
- [ ] Agregar página de "verificación exitosa" en el frontend

## ⚠️ Notas importantes

- El campo `isVerified` comienza en `false` por defecto
- El campo `isActive` comienza en `true` por defecto
- En producción, deberías usar tokens en lugar de userId en la URL
- Los logs con emoji 📧 son solo para desarrollo
- No se envían emails reales en esta implementación
