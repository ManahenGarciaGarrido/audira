# 🚀 IMPLEMENTACIÓN PROGRESIVA DEL BACKEND - REGISTRO DE USUARIOS

Este directorio contiene todos los archivos necesarios para implementar progresivamente las 4 subtareas del sistema de registro de usuarios.

## 📂 Estructura

```
implementacion-progresiva/
├── README.md (este archivo)
├── subtarea1/ - Formulario de registro (Manahen)
│   ├── README.md
│   ├── User.java
│   ├── RegisterRequest.java
│   ├── UserRepository.java
│   ├── UserService.java
│   ├── AuthController.java
│   └── application.yml
├── subtarea2/ - Validación de email único (Eduardo)
│   ├── README.md
│   ├── UserRepository.java (actualizado)
│   ├── UserService.java (actualizado)
│   └── GlobalExceptionHandler.java (nuevo)
├── subtarea3/ - Opción rol Miembro/Artista (Manahen)
│   ├── README.md
│   ├── UserRole.java (nuevo)
│   ├── User.java (actualizado)
│   ├── RegisterRequest.java (actualizado)
│   └── UserService.java (actualizado)
└── subtarea4/ - Confirmación por email simulada (Eduardo)
    ├── README.md
    ├── User.java (actualizado)
    ├── UserService.java (actualizado)
    └── AuthController.java (actualizado)
```

## 🎯 Asignación de Tareas

### Manahen:
- ✅ Subtarea 1: Formulario de registro
- ✅ Subtarea 3: Opción rol Miembro/Artista

### Eduardo:
- ✅ Subtarea 2: Validación de email único
- ✅ Subtarea 4: Confirmación por email simulada

## 📋 Orden de Implementación

### 1️⃣ SUBTAREA 1: Formulario de registro (Manahen)
**Objetivo:** Crear estructura básica y endpoint de registro

**Archivos a crear:**
- `model/User.java`
- `dto/RegisterRequest.java`
- `repository/UserRepository.java`
- `service/UserService.java`
- `controller/AuthController.java`
- `resources/application.yml`

**Resultado:**
- ✅ Endpoint POST `/api/auth/register` funcional
- ✅ Guarda usuarios en base de datos

---

### 2️⃣ SUBTAREA 2: Validación de email único (Eduardo)
**Objetivo:** Evitar registros duplicados

**Archivos a modificar:**
- `repository/UserRepository.java` - Agregar `existsByEmail()` y `existsByUsername()`
- `service/UserService.java` - Agregar validaciones

**Archivos a crear:**
- `exception/GlobalExceptionHandler.java` - Manejo de errores

**Resultado:**
- ✅ Validación de email único
- ✅ Validación de username único
- ✅ Mensajes de error claros

---

### 3️⃣ SUBTAREA 3: Opción rol Miembro/Artista (Manahen)
**Objetivo:** Permitir seleccionar tipo de usuario

**Archivos a crear:**
- `model/UserRole.java` - Enum con USER, ARTIST, ADMIN

**Archivos a modificar:**
- `model/User.java` - Agregar campo `role`
- `dto/RegisterRequest.java` - Agregar campo `role`
- `service/UserService.java` - Asignar rol al registrar

**Resultado:**
- ✅ Campo `role` en modelo User
- ✅ Selector de rol USER/ARTIST en registro
- ✅ Por defecto USER si no se especifica

---

### 4️⃣ SUBTAREA 4: Confirmación por email simulada (Eduardo)
**Objetivo:** Sistema de verificación de email

**Archivos a modificar:**
- `model/User.java` - Agregar `isActive` e `isVerified`
- `service/UserService.java` - Agregar método `verifyEmail()` y logs
- `controller/AuthController.java` - Agregar endpoint `/verify-email/{userId}`

**Resultado:**
- ✅ Campo `isVerified` en User
- ✅ Logs simulando envío de email
- ✅ Endpoint POST `/api/auth/verify-email/{userId}`
- ✅ Flujo completo de verificación

---

## 🛠️ Cómo Usar Este Material

### Para implementar en el repositorio oficial:

#### Opción 1: Copiar archivos manualmente
```bash
# Desde este repositorio (audira)
cd /home/user/audira/implementacion-progresiva

# Copiar archivos de subtarea1 al repositorio oficial
# Repetir para cada subtarea en orden
```

#### Opción 2: Usar como referencia
1. Abre el README de cada subtarea
2. Lee los objetivos y cambios necesarios
3. Copia el código de los archivos correspondientes
4. Pega en tu repositorio oficial siguiendo la estructura de carpetas

### Para verificar que todo funciona:

#### Después de Subtarea 1:
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"password123","firstName":"John","lastName":"Doe"}'
```

#### Después de Subtarea 2:
```bash
# Debe fallar si intentas registrar el mismo email
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser2","password":"password123","firstName":"Jane","lastName":"Doe"}'
```

#### Después de Subtarea 3:
```bash
# Registrar como artista
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"artist@example.com","username":"artist1","password":"password123","firstName":"Bob","lastName":"Artist","role":"ARTIST"}'
```

#### Después de Subtarea 4:
```bash
# Verificar email
curl -X POST http://localhost:9001/api/auth/verify-email/1
```

---

## 📊 Estado Final del Backend

Después de completar las 4 subtareas, tendrás:

### Endpoints:
- `POST /api/auth/register` - Registrar usuario
- `POST /api/auth/verify-email/{userId}` - Verificar email

### Modelo User con:
- ✅ Campos básicos (email, username, password, firstName, lastName)
- ✅ Campo `role` (USER, ARTIST, ADMIN)
- ✅ Campo `isActive` (activo/inactivo)
- ✅ Campo `isVerified` (email confirmado o no)
- ✅ Timestamps (createdAt, updatedAt)

### Validaciones:
- ✅ Email único
- ✅ Username único
- ✅ Email válido
- ✅ Password mínimo 6 caracteres
- ✅ Campos requeridos

### Funcionalidades:
- ✅ Registro de usuarios
- ✅ Selección de rol (Miembro/Artista)
- ✅ Simulación de confirmación por email
- ✅ Logs informativos
- ✅ Manejo de errores

---

## 🔮 Mejoras Futuras (NO incluidas en estas subtareas)

### Seguridad:
- 🔒 Encriptación de contraseñas con BCrypt
- 🔑 Autenticación con JWT
- 🔐 Spring Security completo
- 🛡️ Tokens de verificación únicos (en lugar de userId)

### Funcionalidades:
- 📧 Envío real de emails (JavaMail, SendGrid)
- 🎨 Campos adicionales para artistas (artistName, bio, etc.)
- 👥 Sistema de followers/following
- 🖼️ Upload de imágenes de perfil
- 🔄 Reenviar email de verificación
- ⏰ Expiración de tokens de verificación

---

## 📞 Contacto y Soporte

Si tienes dudas:
1. Lee el README.md de la subtarea específica
2. Revisa los comentarios en el código
3. Consulta el documento principal: `/home/user/audira/PLAN_IMPLEMENTACION_BACKEND.md`
4. Compara con el código completo en: `community-service/src/main/java/io/audira/community/`

---

## ✅ Checklist General

### Antes de empezar:
- [ ] PostgreSQL instalado y corriendo (puerto 5432)
- [ ] Base de datos `audira_community` creada
- [ ] Maven instalado
- [ ] Java 17+ instalado

### Después de cada subtarea:
- [ ] Código compila sin errores
- [ ] Servicio arranca correctamente
- [ ] Pruebas con curl funcionan
- [ ] Datos se guardan en base de datos
- [ ] Logs se muestran correctamente

### Al finalizar todas las subtareas:
- [ ] Todos los endpoints funcionan
- [ ] Validaciones funcionan correctamente
- [ ] Roles se asignan correctamente
- [ ] Verificación de email funciona
- [ ] Frontend conecta correctamente con backend

---

**Fecha de creación:** 2025-11-03
**Versión:** 1.0
**Autores:** Manahen (Subtareas 1 y 3) + Eduardo (Subtareas 2 y 4)
**Asistente:** Claude Code
