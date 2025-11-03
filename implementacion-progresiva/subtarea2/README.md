# SUBTAREA 2: VALIDACIÓN DE EMAIL ÚNICO (Eduardo)

## 🎯 Objetivo
Validar que el email y username no existan antes de registrar un nuevo usuario.

## 📝 Cambios sobre Subtarea 1

Esta subtarea agrega validaciones de duplicados antes de crear el usuario.

## 📁 Archivos a modificar

### 1. UserRepository (agregar métodos de validación)
**Ruta:** `src/main/java/io/audira/community/repository/UserRepository.java`

### 2. UserService (agregar validaciones)
**Ruta:** `src/main/java/io/audira/community/service/UserService.java`

### 3. GlobalExceptionHandler (opcional pero recomendado)
**Ruta:** `src/main/java/io/audira/community/exception/GlobalExceptionHandler.java`

## 🧪 Cómo probar

### Prueba 1: Registrar usuario nuevo (debe funcionar)
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Prueba 2: Intentar registrar con mismo email (debe fallar)
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser2",
    "password": "password123",
    "firstName": "Jane",
    "lastName": "Doe"
  }'
```

### Respuesta esperada (error):
```json
{
  "error": "Email already in use"
}
```

### Prueba 3: Intentar registrar con mismo username (debe fallar)
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "another@example.com",
    "username": "testuser",
    "password": "password123",
    "firstName": "Bob",
    "lastName": "Smith"
  }'
```

### Respuesta esperada (error):
```json
{
  "error": "Username already in use"
}
```

## ✅ Checklist

- [ ] Agregar métodos `existsByEmail()` y `existsByUsername()` a UserRepository
- [ ] Agregar validaciones en UserService.registerUser()
- [ ] Crear GlobalExceptionHandler para manejar errores
- [ ] Probar registro con email duplicado
- [ ] Probar registro con username duplicado
- [ ] Verificar mensajes de error claros

## 🔄 Diferencias con Subtarea 1

### Antes (Subtarea 1):
```java
@Transactional
public User registerUser(RegisterRequest request) {
    User user = User.builder()
            .email(request.getEmail())
            ...
            .build();
    return userRepository.save(user);
}
```

### Después (Subtarea 2):
```java
@Transactional
public User registerUser(RegisterRequest request) {
    // NUEVAS VALIDACIONES
    if (userRepository.existsByEmail(request.getEmail())) {
        throw new RuntimeException("Email already in use");
    }
    if (userRepository.existsByUsername(request.getUsername())) {
        throw new RuntimeException("Username already in use");
    }

    User user = User.builder()
            .email(request.getEmail())
            ...
            .build();
    return userRepository.save(user);
}
```

## ⚠️ Notas importantes

- Las restricciones `unique = true` en la base de datos también previenen duplicados
- Las validaciones en código dan mensajes de error más claros
- El GlobalExceptionHandler es opcional pero mejora la experiencia
