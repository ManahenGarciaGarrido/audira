# 📂 DISTRIBUCIÓN COMPLETA DE ARCHIVOS POR SUBTAREA

Este documento detalla TODOS los archivos necesarios para que cada subtarea funcione correctamente.

---

## 🎯 SUBTAREA 1: Formulario de Registro (Manahen)

### **Objetivo**
Crear la infraestructura completa de Spring Security + JWT + endpoint de registro básico.

### **Archivos necesarios**

#### **Config (2 archivos)**
```
config/
├── CorsConfig.java                  ✅ NECESARIO - Configuración CORS
└── SecurityConfig.java              ✅ NECESARIO - Spring Security + JWT
```

#### **Controller (1 archivo)**
```
controller/
└── AuthController.java              ✅ NECESARIO - Endpoint POST /api/auth/register
```

#### **DTO (3 archivos)**
```
dto/
├── AuthResponse.java                ✅ NECESARIO - Respuesta con token + user
├── RegisterRequest.java             ✅ NECESARIO - Datos del formulario (SIN role)
└── UserDTO.java                     ✅ NECESARIO - Datos del usuario (SIN role, SIN isActive/isVerified)
```

#### **Exception (2 archivos)**
```
exception/
├── ErrorResponse.java               ✅ NECESARIO - Formato de errores
└── GlobalExceptionHandler.java      ✅ NECESARIO - Manejo global de excepciones
```

#### **Model (1 archivo - versión básica)**
```
model/
└── User.java                        ✅ NECESARIO - Modelo básico (NO abstracto, SIN herencia, SIN role)
```

#### **Repository (1 archivo)**
```
repository/
└── UserRepository.java              ✅ NECESARIO - Operaciones de BD (SIN existsByEmail/Username aún)
```

#### **Security (5 archivos)**
```
security/
├── CustomUserDetailsService.java   ✅ NECESARIO - Carga usuarios para autenticación
├── JwtAuthenticationEntryPoint.java ✅ NECESARIO - Manejo de errores 401
├── JwtAuthenticationFilter.java    ✅ NECESARIO - Filtro JWT (bypass /api/auth/**)
├── JwtTokenProvider.java           ✅ NECESARIO - Genera y valida tokens JWT
└── UserPrincipal.java              ✅ NECESARIO - UserDetails para Spring Security (SIN role)
```

#### **Service (1 archivo)**
```
service/
└── UserService.java                 ✅ NECESARIO - registerUser() + loginUser()
```

#### **Resources (1 archivo)**
```
resources/
└── application.yml                  ✅ NECESARIO - Configuración BD + JWT
```

### **Total: 17 archivos**

---

## 🎯 SUBTAREA 2: Validación de Email Único (Eduardo)

### **Objetivo**
Agregar validaciones de email y username únicos antes de registrar.

### **Archivos a MODIFICAR** (todos heredados de Subtarea 1)
```
repository/
└── UserRepository.java              🔄 MODIFICAR - Agregar existsByEmail() y existsByUsername()

service/
└── UserService.java                 🔄 MODIFICAR - Agregar validaciones en registerUser()
```

### **Archivos sin cambios** (16 archivos de Subtarea 1)
Todos los demás archivos permanecen igual.

### **Total: 17 archivos (2 modificados)**

---

## 🎯 SUBTAREA 3: Opción Rol Miembro/Artista (Manahen)

### **Objetivo**
Implementar sistema de herencia con roles USER y ARTIST.

### **Archivos NUEVOS** (3 archivos)
```
model/
├── UserRole.java                    ➕ NUEVO - Enum con USER, ARTIST, ADMIN
├── Artist.java                      ➕ NUEVO - Extiende User
└── RegularUser.java                 ➕ NUEVO - Extiende User
```

### **Archivos a MODIFICAR** (6 archivos)
```
model/
└── User.java                        🔄 MODIFICAR - Hacer abstracta, agregar @Inheritance, agregar campo role

dto/
├── RegisterRequest.java             🔄 MODIFICAR - Agregar campo role (default USER)
└── UserDTO.java                     🔄 MODIFICAR - Agregar campo role

service/
└── UserService.java                 🔄 MODIFICAR - Crear Artist o RegularUser según rol

security/
└── UserPrincipal.java              🔄 MODIFICAR - Manejar rol en authorities
```

### **Archivos sin cambios** (11 archivos)
Config, controllers, exception, repository, y demás archivos de seguridad.

### **Total: 20 archivos (3 nuevos + 17 de Subtarea 2)**

---

## 🎯 SUBTAREA 4: Confirmación por Email Simulada (Eduardo)

### **Objetivo**
Agregar campos isActive e isVerified + endpoint de verificación.

### **Archivos a MODIFICAR** (7 archivos)
```
model/
├── User.java                        🔄 MODIFICAR - Agregar isActive, isVerified, @PrePersist
├── Artist.java                      🔄 MODIFICAR - Heredar isActive, isVerified
└── RegularUser.java                 🔄 MODIFICAR - Heredar isActive, isVerified

dto/
└── UserDTO.java                     🔄 MODIFICAR - Agregar isActive, isVerified

controller/
└── AuthController.java              🔄 MODIFICAR - Agregar endpoint POST /verify-email/{userId}

service/
└── UserService.java                 🔄 MODIFICAR - Agregar verifyEmail(), logs simulados
```

### **Archivos sin cambios** (13 archivos)
Config, exception, repository, security.

### **Total: 20 archivos (7 modificados)**

---

## 📊 RESUMEN EJECUTIVO

| Subtarea | Archivos Totales | Nuevos | Modificados | Sin Cambios |
|----------|------------------|--------|-------------|-------------|
| **1**    | 17               | 17     | -           | -           |
| **2**    | 17               | -      | 2           | 15          |
| **3**    | 20               | 3      | 6           | 11          |
| **4**    | 20               | -      | 7           | 13          |

---

## 🗂️ ESTRUCTURA COMPLETA FINAL (Subtarea 4)

```
community-service/
└── src/main/java/io/audira/community/
    ├── config/
    │   ├── CorsConfig.java
    │   └── SecurityConfig.java
    ├── controller/
    │   ├── AuthController.java
    │   └── UserController.java (OPCIONAL - no en subtareas básicas)
    ├── dto/
    │   ├── AuthResponse.java
    │   ├── RegisterRequest.java
    │   └── UserDTO.java
    ├── exception/
    │   ├── ErrorResponse.java
    │   └── GlobalExceptionHandler.java
    ├── model/
    │   ├── User.java (abstracta)
    │   ├── UserRole.java
    │   ├── Artist.java
    │   └── RegularUser.java
    ├── repository/
    │   └── UserRepository.java
    ├── security/
    │   ├── CustomUserDetailsService.java
    │   ├── JwtAuthenticationEntryPoint.java
    │   ├── JwtAuthenticationFilter.java
    │   ├── JwtTokenProvider.java
    │   └── UserPrincipal.java
    └── service/
        └── UserService.java
```

---

## ⚠️ NOTAS IMPORTANTES

1. **UserController.java NO está incluido** en las subtareas básicas porque:
   - No es necesario para el registro
   - Requiere autenticación para todos sus endpoints
   - Se puede agregar después como mejora

2. **Todos los archivos de seguridad son NECESARIOS desde Subtarea 1** porque:
   - Spring Security requiere toda la configuración completa
   - El filtro JWT debe existir aunque haga bypass de `/api/auth/**`
   - AuthResponse devuelve un token JWT
   - Sin estos archivos, el servicio no arranca correctamente

3. **La herencia se implementa en Subtarea 3** para mantener simplicidad:
   - Subtarea 1-2: User es una clase concreta normal
   - Subtarea 3: User se convierte en abstracta con Artist y RegularUser

4. **application.yml** debe incluir:
   - Configuración de PostgreSQL
   - Configuración JWT (secret + expiration)
   - Deshabilitación de Eureka (opcional)

---

## 🚀 ORDEN DE IMPLEMENTACIÓN RECOMENDADO

1. **Subtarea 1**: Copiar los 17 archivos → Probar registro básico
2. **Subtarea 2**: Modificar 2 archivos → Probar validación de duplicados
3. **Subtarea 3**: Agregar 3 archivos + modificar 6 → Probar registro con roles
4. **Subtarea 4**: Modificar 7 archivos → Probar verificación de email

---

**Fecha de creación:** 2025-11-03
**Versión:** 2.0 - Distribución completa con todos los archivos de seguridad
