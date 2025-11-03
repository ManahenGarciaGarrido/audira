# SUBTAREA 1: FORMULARIO DE REGISTRO (Manahen)

## 🎯 Objetivo
Crear el endpoint básico de registro que acepte datos del formulario.

## 📁 Archivos a crear

### 1. Modelo User (básico)
**Ruta:** `src/main/java/io/audira/community/model/User.java`

### 2. DTO RegisterRequest
**Ruta:** `src/main/java/io/audira/community/dto/RegisterRequest.java`

### 3. Repository UserRepository
**Ruta:** `src/main/java/io/audira/community/repository/UserRepository.java`

### 4. Service UserService (versión básica)
**Ruta:** `src/main/java/io/audira/community/service/UserService.java`

### 5. Controller AuthController
**Ruta:** `src/main/java/io/audira/community/controller/AuthController.java`

### 6. Configuración application.yml
**Ruta:** `src/main/resources/application.yml`

## 🧪 Cómo probar

### Iniciar servicio:
```bash
cd community-service
mvn spring-boot:run
```

### Probar endpoint:
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

### Respuesta esperada:
```json
{
  "id": 1,
  "email": "test@example.com",
  "username": "testuser",
  "firstName": "John",
  "lastName": "Doe",
  "createdAt": "2025-11-03T10:30:00",
  "updatedAt": "2025-11-03T10:30:00"
}
```

## ✅ Checklist

- [ ] Crear modelo User con campos básicos
- [ ] Crear DTO RegisterRequest con validaciones
- [ ] Crear UserRepository que extienda JpaRepository
- [ ] Crear UserService con método registerUser
- [ ] Crear AuthController con endpoint POST /api/auth/register
- [ ] Configurar application.yml con base de datos
- [ ] Probar con curl o Postman
- [ ] Verificar que se guarda en base de datos

## ⚠️ Notas importantes

- Por ahora la contraseña se guarda en texto plano (se mejorará en siguientes pasos)
- No hay validación de duplicados todavía (se agrega en subtarea 2)
- No hay campo de rol todavía (se agrega en subtarea 3)
- No hay verificación de email todavía (se agrega en subtarea 4)

## 📦 Dependencias necesarias

Asegúrate de tener en tu `pom.xml`:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
</dependency>
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>
```
