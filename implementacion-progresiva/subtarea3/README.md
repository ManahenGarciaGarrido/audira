# SUBTAREA 3: OPCIÓN ROL MIEMBRO/ARTISTA (Manahen)

## 🎯 Objetivo
Permitir al usuario seleccionar entre rol USER (Miembro) o ARTIST (Artista) al registrarse.

## 📝 Cambios sobre Subtarea 2

Esta subtarea agrega la capacidad de diferenciar entre usuarios regulares y artistas.

## 📁 Archivos a crear/modificar

### 1. UserRole (NUEVO - Enum)
**Ruta:** `src/main/java/io/audira/community/model/UserRole.java`

### 2. User (modificar - agregar campo role)
**Ruta:** `src/main/java/io/audira/community/model/User.java`

### 3. RegisterRequest (modificar - agregar campo role)
**Ruta:** `src/main/java/io/audira/community/dto/RegisterRequest.java`

### 4. UserService (modificar - asignar rol)
**Ruta:** `src/main/java/io/audira/community/service/UserService.java`

## 🧪 Cómo probar

### Prueba 1: Registrar como USER (Miembro) - por defecto
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "member@example.com",
    "username": "member1",
    "password": "password123",
    "firstName": "John",
    "lastName": "Member"
  }'
```

### Respuesta esperada:
```json
{
  "id": 1,
  "email": "member@example.com",
  "username": "member1",
  "firstName": "John",
  "lastName": "Member",
  "role": "USER",
  ...
}
```

### Prueba 2: Registrar como USER (Miembro) - explícito
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "member2@example.com",
    "username": "member2",
    "password": "password123",
    "firstName": "Jane",
    "lastName": "Member",
    "role": "USER"
  }'
```

### Prueba 3: Registrar como ARTIST (Artista)
```bash
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "artist@example.com",
    "username": "artist1",
    "password": "password123",
    "firstName": "Bob",
    "lastName": "Artist",
    "role": "ARTIST"
  }'
```

### Respuesta esperada:
```json
{
  "id": 2,
  "email": "artist@example.com",
  "username": "artist1",
  "firstName": "Bob",
  "lastName": "Artist",
  "role": "ARTIST",
  ...
}
```

## ✅ Checklist

- [ ] Crear enum UserRole con valores USER, ARTIST, ADMIN
- [ ] Agregar campo `role` al modelo User
- [ ] Agregar campo `role` a RegisterRequest (con valor por defecto USER)
- [ ] Actualizar UserService para asignar el rol
- [ ] Probar registro sin especificar rol (debe ser USER por defecto)
- [ ] Probar registro como USER explícitamente
- [ ] Probar registro como ARTIST
- [ ] Verificar en base de datos que el campo role se guarda correctamente

## 🔄 Diferencias con Subtarea 2

### Modelo User - Antes (Subtarea 2):
```java
@Entity
@Table(name = "users")
public class User {
    private Long id;
    private String email;
    private String username;
    // ... otros campos
}
```

### Modelo User - Después (Subtarea 3):
```java
@Entity
@Table(name = "users")
public class User {
    private Long id;
    private String email;
    private String username;
    // ... otros campos

    // NUEVO CAMPO
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;
}
```

## 🎨 Frontend - Selector de Rol

En el frontend, puedes implementar un selector así:

```html
<select name="role">
  <option value="USER">Miembro</option>
  <option value="ARTIST">Artista</option>
</select>
```

O con radio buttons:
```html
<input type="radio" name="role" value="USER" checked> Miembro
<input type="radio" name="role" value="ARTIST"> Artista
```

## 🔮 Notas para futuras mejoras

En el backend completo de Audira, los artistas tienen:
- `artistName` (nombre artístico)
- `verificationLevel` (UNVERIFIED, VERIFIED, VERIFIED_PLUS)
- `artistBio` (biografía artística)
- `label` (sello discográfico)

Pero para esta subtarea solo implementamos el campo `role` básico.

## ⚠️ Notas importantes

- El valor por defecto es `USER` si no se especifica
- Los valores válidos son: `USER`, `ARTIST`, `ADMIN`
- El frontend debe enviar el valor como string: "USER" o "ARTIST"
- La base de datos guarda el enum como STRING (no como índice numérico)
