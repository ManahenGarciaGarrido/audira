# 🚀 GUÍA RÁPIDA DE IMPLEMENTACIÓN

## 📍 Archivos Generados

He creado dos recursos principales para ti:

### 1. Documento de Planificación Completo
**Ubicación:** `/home/user/audira/PLAN_IMPLEMENTACION_BACKEND.md`
- Explicación detallada de cada subtarea
- Código completo con comentarios
- Ejemplos de pruebas con curl
- Dependencias necesarias

### 2. Carpeta de Implementación Progresiva
**Ubicación:** `/home/user/audira/implementacion-progresiva/`
- Archivos organizados por subtarea
- READMEs individuales con instrucciones
- Código listo para copiar y pegar

---

## 📊 RESUMEN VISUAL DE SUBTAREAS

```
SUBTAREA 1 (Manahen)                SUBTAREA 2 (Eduardo)
┌─────────────────────┐            ┌─────────────────────┐
│ Formulario Registro │            │ Validación Email    │
├─────────────────────┤            ├─────────────────────┤
│ • User.java         │            │ • UserRepository    │
│ • RegisterRequest   │     +      │   + existsByEmail   │
│ • UserRepository    │            │   + existsByUsername│
│ • UserService       │            │ • UserService       │
│ • AuthController    │            │   + validaciones    │
│ • application.yml   │            │ • ExceptionHandler  │
└─────────────────────┘            └─────────────────────┘
         │                                   │
         └──────────────┬────────────────────┘
                        │
         ┌──────────────┴────────────────┐
         │                               │
SUBTAREA 3 (Manahen)          SUBTAREA 4 (Eduardo)
┌─────────────────────┐      ┌─────────────────────┐
│ Rol Miembro/Artista │      │ Confirmación Email  │
├─────────────────────┤      ├─────────────────────┤
│ • UserRole enum     │  +   │ • User.java         │
│ • User.java         │      │   + isActive        │
│   + campo role      │      │   + isVerified      │
│ • RegisterRequest   │      │ • UserService       │
│   + campo role      │      │   + verifyEmail()   │
│ • UserService       │      │ • AuthController    │
│   + asignar rol     │      │   + /verify-email   │
└─────────────────────┘      └─────────────────────┘
```

---

## 🎯 PASOS PARA IMPLEMENTAR EN EL REPOSITORIO OFICIAL

### Preparación
```bash
# 1. Asegúrate de tener este repositorio clonado
cd /home/user/audira

# 2. Los archivos están en:
ls -la implementacion-progresiva/
```

### Subtarea 1: Formulario de registro (Manahen)
```bash
# Copiar archivos base al repositorio oficial
# Estructura de carpetas a crear:
# src/main/java/io/audira/community/
#   ├── model/User.java
#   ├── dto/RegisterRequest.java
#   ├── repository/UserRepository.java
#   ├── service/UserService.java
#   └── controller/AuthController.java
# src/main/resources/
#   └── application.yml

# Archivos fuente:
# implementacion-progresiva/subtarea1/
```

**Checklist:**
- [ ] Copiar User.java → model/
- [ ] Copiar RegisterRequest.java → dto/
- [ ] Copiar UserRepository.java → repository/
- [ ] Copiar UserService.java → service/
- [ ] Copiar AuthController.java → controller/
- [ ] Copiar application.yml → resources/
- [ ] Compilar y probar endpoint de registro

### Subtarea 2: Validación de email único (Eduardo)
```bash
# Actualizar archivos existentes con las versiones de subtarea2/
# + Agregar GlobalExceptionHandler.java

# Archivos fuente:
# implementacion-progresiva/subtarea2/
```

**Checklist:**
- [ ] Actualizar UserRepository.java (agregar existsByEmail, existsByUsername)
- [ ] Actualizar UserService.java (agregar validaciones)
- [ ] Crear GlobalExceptionHandler.java → exception/
- [ ] Probar registro con email duplicado (debe fallar)
- [ ] Probar registro con username duplicado (debe fallar)

### Subtarea 3: Opción rol Miembro/Artista (Manahen)
```bash
# Crear UserRole.java
# Actualizar User.java, RegisterRequest.java, UserService.java

# Archivos fuente:
# implementacion-progresiva/subtarea3/
```

**Checklist:**
- [ ] Crear UserRole.java → model/
- [ ] Actualizar User.java (agregar campo role)
- [ ] Actualizar RegisterRequest.java (agregar campo role)
- [ ] Actualizar UserService.java (asignar rol)
- [ ] Probar registro como USER
- [ ] Probar registro como ARTIST

### Subtarea 4: Confirmación por email simulada (Eduardo)
```bash
# Actualizar User.java, UserService.java, AuthController.java

# Archivos fuente:
# implementacion-progresiva/subtarea4/
```

**Checklist:**
- [ ] Actualizar User.java (agregar isActive, isVerified)
- [ ] Actualizar UserService.java (agregar verifyEmail(), logs)
- [ ] Actualizar AuthController.java (agregar endpoint /verify-email)
- [ ] Probar registro (ver logs de simulación)
- [ ] Probar verificación de email
- [ ] Verificar que isVerified cambia a true

---

## 🧪 PRUEBAS RÁPIDAS

### Test Subtarea 1:
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"password123","firstName":"John","lastName":"Doe"}'
```

### Test Subtarea 2:
```bash
# Intentar registrar mismo email (debe fallar)
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser2","password":"password123","firstName":"Jane","lastName":"Doe"}'
```

### Test Subtarea 3:
```bash
# Registrar como artista
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"artist@example.com","username":"artist1","password":"password123","firstName":"Bob","lastName":"Artist","role":"ARTIST"}'
```

### Test Subtarea 4:
```bash
# Verificar email (reemplazar 1 con el ID del usuario)
curl -X POST http://localhost:9001/api/auth/verify-email/1
```

---

## 📂 MAPEO DE ARCHIVOS

### Desde este repositorio → Al repositorio oficial

| Archivo en audira | Destino en repositorio oficial |
|-------------------|-------------------------------|
| `subtarea1/User.java` | `src/main/java/io/audira/community/model/User.java` |
| `subtarea1/RegisterRequest.java` | `src/main/java/io/audira/community/dto/RegisterRequest.java` |
| `subtarea1/UserRepository.java` | `src/main/java/io/audira/community/repository/UserRepository.java` |
| `subtarea1/UserService.java` | `src/main/java/io/audira/community/service/UserService.java` |
| `subtarea1/AuthController.java` | `src/main/java/io/audira/community/controller/AuthController.java` |
| `subtarea1/application.yml` | `src/main/resources/application.yml` |
| `subtarea2/GlobalExceptionHandler.java` | `src/main/java/io/audira/community/exception/GlobalExceptionHandler.java` |
| `subtarea3/UserRole.java` | `src/main/java/io/audira/community/model/UserRole.java` |

---

## 📦 DEPENDENCIAS NECESARIAS (pom.xml)

```xml
<dependencies>
    <!-- Spring Boot Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- Spring Boot JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <!-- Validaciones -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>

    <!-- PostgreSQL -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>

    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

---

## 🔍 DIFERENCIAS ENTRE SUBTAREAS

### Subtarea 1 → Subtarea 2
- ✅ Agregar métodos `existsByEmail()` y `existsByUsername()` a UserRepository
- ✅ Agregar validaciones en UserService antes de guardar
- ✅ Crear GlobalExceptionHandler para errores consistentes

### Subtarea 2 → Subtarea 3
- ✅ Crear enum UserRole (USER, ARTIST, ADMIN)
- ✅ Agregar campo `role` a User
- ✅ Agregar campo `role` a RegisterRequest con default USER
- ✅ Asignar rol en UserService.registerUser()

### Subtarea 3 → Subtarea 4
- ✅ Agregar campos `isActive` e `isVerified` a User
- ✅ Inicializar en @PrePersist (isActive=true, isVerified=false)
- ✅ Agregar logs de simulación en registerUser()
- ✅ Crear método verifyEmail() en UserService
- ✅ Crear endpoint POST /api/auth/verify-email/{userId}

---

## 🎓 RECOMENDACIONES

### Para Manahen (Subtareas 1 y 3):
1. **Subtarea 1:** Empieza con la estructura base
   - Crea las carpetas (model, dto, repository, service, controller)
   - Copia los archivos uno por uno
   - Compila después de cada archivo
   - Prueba el endpoint cuando termines

2. **Subtarea 3:** Agrega el sistema de roles
   - Crea el enum UserRole primero
   - Actualiza User.java
   - Actualiza RegisterRequest.java
   - Actualiza UserService.java
   - Prueba con ambos roles (USER y ARTIST)

### Para Eduardo (Subtareas 2 y 4):
1. **Subtarea 2:** Agrega validaciones
   - Actualiza UserRepository con los métodos exists
   - Agrega las validaciones en UserService
   - Crea el GlobalExceptionHandler
   - Prueba intentando registrar duplicados

2. **Subtarea 4:** Implementa verificación
   - Actualiza User con isActive e isVerified
   - Agrega el método verifyEmail en UserService
   - Agrega el endpoint en AuthController
   - Prueba el flujo completo: registro → verificación

---

## 🚨 ERRORES COMUNES Y SOLUCIONES

### Error: "Could not resolve placeholder 'spring.datasource.url'"
**Solución:** Asegúrate de que application.yml esté en `src/main/resources/`

### Error: "Bean UserRepository could not be found"
**Solución:** Verifica que las anotaciones @Repository, @Service, @RestController estén presentes

### Error: "Table 'users' doesn't exist"
**Solución:** Asegúrate de que `spring.jpa.hibernate.ddl-auto` esté en `update` y reinicia el servicio

### Error: "Duplicate entry for email"
**Solución:** Esto es esperado en Subtarea 2 - es la validación funcionando

### Error: "User not found" al verificar email
**Solución:** Usa el ID correcto del usuario registrado (mira la respuesta del registro)

---

## ✅ CHECKLIST FINAL

### Backend completo implementado:
- [ ] Subtarea 1 completada y probada
- [ ] Subtarea 2 completada y probada
- [ ] Subtarea 3 completada y probada
- [ ] Subtarea 4 completada y probada
- [ ] Todos los tests manuales pasan
- [ ] Base de datos tiene las tablas correctas
- [ ] Frontend conecta correctamente
- [ ] Código commiteado en el repositorio oficial

---

**Éxito! 🎉** Una vez completadas las 4 subtareas, tendrás un sistema completo de registro con validaciones, roles y verificación de email simulada.

Si encuentras algún problema, revisa los READMEs individuales de cada subtarea o consulta el documento completo: `PLAN_IMPLEMENTACION_BACKEND.md`
