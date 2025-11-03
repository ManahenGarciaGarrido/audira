# 📋 GUÍA DE COPIA DE ARCHIVOS DEL BACKEND COMPLETO

Esta guía te indica **exactamente qué archivos** copiar desde tu backend completo (`community-service/`) a las carpetas de implementación progresiva.

---

## 🎯 SUBTAREA 1: Formulario de Registro (17 archivos)

### Copiar DESDE `community-service/src/main/java/io/audira/community/`

```bash
# Config (2 archivos)
config/CorsConfig.java                   → implementacion-progresiva/subtarea1/config/
config/SecurityConfig.java               → implementacion-progresiva/subtarea1/config/

# Controller (1 archivo)
controller/AuthController.java           → implementacion-progresiva/subtarea1/controller/

# DTO (3 archivos)
dto/AuthResponse.java                    → implementacion-progresiva/subtarea1/dto/
dto/RegisterRequest.java                 → implementacion-progresiva/subtarea1/dto/
dto/UserDTO.java                         → implementacion-progresiva/subtarea1/dto/

# Exception (2 archivos)
exception/ErrorResponse.java             → implementacion-progresiva/subtarea1/exception/
exception/GlobalExceptionHandler.java    → implementacion-progresiva/subtarea1/exception/

# Model (1 archivo)
model/User.java                          → implementacion-progresiva/subtarea1/model/

# Repository (1 archivo)
repository/UserRepository.java           → implementacion-progresiva/subtarea1/repository/

# Security (5 archivos)
security/CustomUserDetailsService.java   → implementacion-progresiva/subtarea1/security/
security/JwtAuthenticationEntryPoint.java → implementacion-progresiva/subtarea1/security/
security/JwtAuthenticationFilter.java    → implementacion-progresiva/subtarea1/security/
security/JwtTokenProvider.java           → implementacion-progresiva/subtarea1/security/
security/UserPrincipal.java              → implementacion-progresiva/subtarea1/security/

# Service (1 archivo)
service/UserService.java                 → implementacion-progresiva/subtarea1/service/
```

### Copiar DESDE `community-service/src/main/resources/`

```bash
application.yml                          → implementacion-progresiva/subtarea1/resources/
```

### ⚠️ MODIFICACIONES NECESARIAS PARA SUBTAREA 1

Después de copiar, **MODIFICA** estos archivos:

#### `model/User.java`
- ❌ **ELIMINAR** anotaciones de herencia:
  - `@Inheritance(strategy = InheritanceType.JOINED)`
  - `@DiscriminatorColumn(...)`
- ❌ **ELIMINAR** `abstract` de la clase (debe ser clase concreta)
- ❌ **ELIMINAR** campo `role` y anotación `@Enumerated`
- ❌ **ELIMINAR** método `public abstract String getUserType();`
- ❌ **ELIMINAR** campos `isActive` e `isVerified`

```java
// VERSIÓN SUBTAREA 1 - Sin herencia, sin role, sin isActive/isVerified
@Entity
@Table(name = "users")
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class User {  // NO abstracta
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ... campos básicos (email, username, password, etc.)
    // SIN role, SIN isActive, SIN isVerified
}
```

#### `dto/RegisterRequest.java`
- ❌ **ELIMINAR** campo `role`

#### `dto/UserDTO.java`
- ❌ **ELIMINAR** campo `role`
- ❌ **ELIMINAR** campos `isActive` e `isVerified`

#### `security/UserPrincipal.java`
- 🔄 **MODIFICAR** método `create()` para no usar `user.getRole()`
- Usar autoridad fija: `ROLE_USER`

```java
public static UserPrincipal create(User user) {
    Collection<GrantedAuthority> authorities = Collections.singletonList(
            new SimpleGrantedAuthority("ROLE_USER")  // Fijo para Subtarea 1
    );
    // ...
}
```

---

## 🎯 SUBTAREA 2: Validación de Email Único (17 archivos)

### Copiar TODO de Subtarea 1
```bash
cp -r implementacion-progresiva/subtarea1/* implementacion-progresiva/subtarea2/
```

### MODIFICAR estos 2 archivos:

#### `repository/UserRepository.java`
- ➕ **AGREGAR** métodos:

```java
Boolean existsByEmail(String email);
Boolean existsByUsername(String username);
```

#### `service/UserService.java`
- ➕ **AGREGAR** validaciones en `registerUser()`:

```java
if (userRepository.existsByEmail(request.getEmail())) {
    throw new RuntimeException("Email already in use");
}
if (userRepository.existsByUsername(request.getUsername())) {
    throw new RuntimeException("Username already in use");
}
```

---

## 🎯 SUBTAREA 3: Opción Rol Miembro/Artista (20 archivos)

### Copiar TODO de Subtarea 2
```bash
cp -r implementacion-progresiva/subtarea2/* implementacion-progresiva/subtarea3/
```

### AGREGAR 3 archivos NUEVOS desde el backend completo:

```bash
model/UserRole.java                      → implementacion-progresiva/subtarea3/model/
model/Artist.java                        → implementacion-progresiva/subtarea3/model/
model/RegularUser.java                   → implementacion-progresiva/subtarea3/model/
```

### MODIFICAR estos 6 archivos:

#### `model/User.java`
- ➕ **AGREGAR** anotaciones de herencia:
```java
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "user_type", discriminatorType = DiscriminatorType.STRING)
```
- ➕ **HACER** la clase `abstract`
- ➕ **AGREGAR** campo `role`:
```java
@Enumerated(EnumType.STRING)
@Column(nullable = false)
private UserRole role;
```
- ➕ **AGREGAR** método abstracto:
```java
public abstract String getUserType();
```

#### `dto/RegisterRequest.java`
- ➕ **AGREGAR** campo:
```java
private UserRole role = UserRole.USER;
```

#### `dto/UserDTO.java`
- ➕ **AGREGAR** campo:
```java
private UserRole role;
```

#### `service/UserService.java`
- 🔄 **REEMPLAZAR** lógica de `registerUser()` para crear Artist o RegularUser según el rol (copiar del backend completo)

#### `security/UserPrincipal.java`
- 🔄 **REEMPLAZAR** método `create()` para usar `user.getRole()` (copiar del backend completo)

---

## 🎯 SUBTAREA 4: Confirmación por Email (20 archivos)

### Copiar TODO de Subtarea 3
```bash
cp -r implementacion-progresiva/subtarea3/* implementacion-progresiva/subtarea4/
```

### MODIFICAR estos 7 archivos:

#### `model/User.java`
- ➕ **AGREGAR** campos:
```java
@Column(nullable = false)
private Boolean isActive;

@Column(nullable = false)
private Boolean isVerified;
```
- ➕ **AGREGAR** en `@PrePersist`:
```java
if (this.isActive == null) {
    this.isActive = true;
}
if (this.isVerified == null) {
    this.isVerified = false;
}
```

#### `model/Artist.java` y `model/RegularUser.java`
- ✅ No necesitan cambios (heredan isActive/isVerified de User)

#### `dto/UserDTO.java`
- ➕ **AGREGAR** campos:
```java
private Boolean isActive;
private Boolean isVerified;
```

#### `controller/AuthController.java`
- ➕ **AGREGAR** endpoint:
```java
@PostMapping("/verify-email/{userId}")
public ResponseEntity<Map<String, Object>> verifyEmail(@PathVariable Long userId) {
    // ... (copiar del backend completo)
}
```

#### `service/UserService.java`
- ➕ **AGREGAR** logs simulados en `registerUser()`:
```java
logger.info("📧 [SIMULADO] Email de verificación enviado a: {}", user.getEmail());
```
- ➕ **AGREGAR** método `verifyEmail()` (copiar del backend completo)

---

## 🚀 SCRIPT DE COPIA AUTOMÁTICA (Bash)

```bash
#!/bin/bash

# Variables
BACKEND_SRC="community-service/src/main/java/io/audira/community"
BACKEND_RES="community-service/src/main/resources"
IMPL_BASE="implementacion-progresiva"

# SUBTAREA 1
echo "Copiando archivos para Subtarea 1..."
mkdir -p $IMPL_BASE/subtarea1/{config,controller,dto,exception,model,repository,security,service,resources}

cp $BACKEND_SRC/config/CorsConfig.java $IMPL_BASE/subtarea1/config/
cp $BACKEND_SRC/config/SecurityConfig.java $IMPL_BASE/subtarea1/config/
cp $BACKEND_SRC/controller/AuthController.java $IMPL_BASE/subtarea1/controller/
cp $BACKEND_SRC/dto/AuthResponse.java $IMPL_BASE/subtarea1/dto/
cp $BACKEND_SRC/dto/RegisterRequest.java $IMPL_BASE/subtarea1/dto/
cp $BACKEND_SRC/dto/UserDTO.java $IMPL_BASE/subtarea1/dto/
cp $BACKEND_SRC/exception/ErrorResponse.java $IMPL_BASE/subtarea1/exception/
cp $BACKEND_SRC/exception/GlobalExceptionHandler.java $IMPL_BASE/subtarea1/exception/
cp $BACKEND_SRC/model/User.java $IMPL_BASE/subtarea1/model/
cp $BACKEND_SRC/repository/UserRepository.java $IMPL_BASE/subtarea1/repository/
cp $BACKEND_SRC/security/*.java $IMPL_BASE/subtarea1/security/
cp $BACKEND_SRC/service/UserService.java $IMPL_BASE/subtarea1/service/
cp $BACKEND_RES/application.yml $IMPL_BASE/subtarea1/resources/

echo "✅ Subtarea 1 completa"

# SUBTAREA 2
echo "Copiando archivos para Subtarea 2..."
cp -r $IMPL_BASE/subtarea1/* $IMPL_BASE/subtarea2/
echo "✅ Subtarea 2 completa (modificar manualmente repository y service)"

# SUBTAREA 3
echo "Copiando archivos para Subtarea 3..."
cp -r $IMPL_BASE/subtarea2/* $IMPL_BASE/subtarea3/
cp $BACKEND_SRC/model/UserRole.java $IMPL_BASE/subtarea3/model/
cp $BACKEND_SRC/model/Artist.java $IMPL_BASE/subtarea3/model/
cp $BACKEND_SRC/model/RegularUser.java $IMPL_BASE/subtarea3/model/
echo "✅ Subtarea 3 completa (modificar manualmente los 6 archivos indicados)"

# SUBTAREA 4
echo "Copiando archivos para Subtarea 4..."
cp -r $IMPL_BASE/subtarea3/* $IMPL_BASE/subtarea4/
echo "✅ Subtarea 4 completa (modificar manualmente los 7 archivos indicados)"

echo ""
echo "✅ TODOS LOS ARCHIVOS COPIADOS"
echo "⚠️  IMPORTANTE: Ahora debes hacer las modificaciones manuales indicadas en GUIA_COPIA_ARCHIVOS.md"
```

---

## 📝 CHECKLIST DE VERIFICACIÓN

### Subtarea 1:
- [ ] 17 archivos copiados
- [ ] User.java modificado (sin herencia, sin role)
- [ ] RegisterRequest.java modificado (sin role)
- [ ] UserDTO.java modificado (sin role, sin isActive/isVerified)
- [ ] UserPrincipal.java modificado (ROLE_USER fijo)
- [ ] application.yml configurado con BD y JWT

### Subtarea 2:
- [ ] Copiado todo de Subtarea 1
- [ ] UserRepository.java modificado (exists methods)
- [ ] UserService.java modificado (validaciones)

### Subtarea 3:
- [ ] Copiado todo de Subtarea 2
- [ ] UserRole.java, Artist.java, RegularUser.java agregados
- [ ] User.java modificado (abstract + herencia + role)
- [ ] RegisterRequest.java modificado (+role)
- [ ] UserDTO.java modificado (+role)
- [ ] UserService.java modificado (crear Artist/RegularUser)
- [ ] UserPrincipal.java modificado (usar role)

### Subtarea 4:
- [ ] Copiado todo de Subtarea 3
- [ ] User.java modificado (+isActive, +isVerified)
- [ ] UserDTO.java modificado (+isActive, +isVerified)
- [ ] AuthController.java modificado (+endpoint verify)
- [ ] UserService.java modificado (+verifyEmail(), +logs)

---

## ⚠️ IMPORTANTE

1. **NO copies UserController.java** - No es necesario para las subtareas básicas
2. **Modifica application.yml** para deshabilitar Eureka si es necesario
3. **Verifica los imports** después de copiar archivos
4. **Prueba cada subtarea** antes de pasar a la siguiente

---

**¿Prefieres que cree los archivos individualmente o usas este script de copia?**
