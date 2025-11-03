# PLAN DE IMPLEMENTACIÓN BACKEND - REGISTRO DE USUARIOS

Este documento detalla el código necesario del backend para implementar progresivamente cada subtarea del sistema de registro.

---

## 📋 SUBTAREAS A IMPLEMENTAR

1. **Formulario de registro** (Manahen)
2. **Validación de email único** (Eduardo)
3. **Opción rol Miembro/Artista** (Manahen)
4. **Confirmación por email simulada** (Eduardo)

---

## 🏗️ ARQUITECTURA BASE NECESARIA

### Estructura de carpetas mínima:
```
backend/
├── src/main/java/io/audira/community/
│   ├── CommunityServiceApplication.java
│   ├── controller/
│   │   └── AuthController.java
│   ├── service/
│   │   └── UserService.java
│   ├── model/
│   │   ├── User.java
│   │   └── UserRole.java
│   ├── repository/
│   │   └── UserRepository.java
│   ├── dto/
│   │   ├── RegisterRequest.java
│   │   └── AuthResponse.java
│   ├── config/
│   │   └── SecurityConfig.java (básica)
│   └── security/
│       └── PasswordEncoder (si no usas Spring Security)
└── resources/
    └── application.yml
```

---

## 📦 SUBTAREA 1: FORMULARIO DE REGISTRO (Manahen)

### Objetivo
Crear el endpoint básico de registro que acepte datos del formulario.

### Archivos necesarios

#### 1.1. `RegisterRequest.java` (DTO)
**Ubicación:** `src/main/java/io/audira/community/dto/RegisterRequest.java`

```java
package io.audira.community.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 100, message = "Password must be at least 6 characters")
    private String password;

    @NotBlank(message = "First name is required")
    private String firstName;

    @NotBlank(message = "Last name is required")
    private String lastName;
}
```

**Dependencias necesarias:**
- `jakarta.validation:jakarta.validation-api` (validaciones)
- `org.projectlombok:lombok` (anotaciones)

---

#### 1.2. `User.java` (Modelo básico)
**Ubicación:** `src/main/java/io/audira/community/model/User.java`

```java
package io.audira.community.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
```

**Dependencias necesarias:**
- `org.springframework.boot:spring-boot-starter-data-jpa`
- `jakarta.persistence:jakarta.persistence-api`

---

#### 1.3. `UserRepository.java`
**Ubicación:** `src/main/java/io/audira/community/repository/UserRepository.java`

```java
package io.audira.community.repository;

import io.audira.community.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);
}
```

---

#### 1.4. `UserService.java` (Versión básica)
**Ubicación:** `src/main/java/io/audira/community/service/UserService.java`

```java
package io.audira.community.service;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public User registerUser(RegisterRequest request) {
        // Por ahora, guardamos la contraseña en texto plano (se mejorará después)
        User user = User.builder()
                .email(request.getEmail())
                .username(request.getUsername())
                .password(request.getPassword())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .build();

        return userRepository.save(user);
    }
}
```

---

#### 1.5. `AuthController.java`
**Ubicación:** `src/main/java/io/audira/community/controller/AuthController.java`

```java
package io.audira.community.controller;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<User> register(@Valid @RequestBody RegisterRequest request) {
        logger.info("Register request received for email: {}", request.getEmail());
        User user = userService.registerUser(request);
        logger.info("User registered successfully: {}", request.getEmail());
        return ResponseEntity.ok(user);
    }
}
```

---

#### 1.6. `application.yml` (Configuración mínima)
**Ubicación:** `src/main/resources/application.yml`

```yaml
server:
  port: 9001

spring:
  application:
    name: community-service

  datasource:
    url: jdbc:postgresql://localhost:5432/audira_community
    username: postgres
    password: postgres
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
```

---

### ✅ Resultado Subtarea 1
- ✅ Endpoint `/api/auth/register` funcional
- ✅ Acepta datos del formulario (email, username, password, firstName, lastName)
- ✅ Validaciones básicas en el DTO
- ✅ Guarda usuario en base de datos

### 🧪 Prueba
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

---

## 📦 SUBTAREA 2: VALIDACIÓN DE EMAIL ÚNICO (Eduardo)

### Objetivo
Validar que el email y username no existan antes de registrar.

### Cambios necesarios

#### 2.1. Actualizar `UserRepository.java`
**Agregar métodos de validación:**

```java
package io.audira.community.repository;

import io.audira.community.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);

    // NUEVOS MÉTODOS
    Boolean existsByEmail(String email);
    Boolean existsByUsername(String username);
}
```

---

#### 2.2. Actualizar `UserService.java`
**Agregar validaciones:**

```java
package io.audira.community.service;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

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
                .username(request.getUsername())
                .password(request.getPassword())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .build();

        return userRepository.save(user);
    }
}
```

---

#### 2.3. (Opcional) Crear manejo de excepciones global
**Ubicación:** `src/main/java/io/audira/community/exception/GlobalExceptionHandler.java`

```java
package io.audira.community.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntimeException(RuntimeException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }
}
```

---

### ✅ Resultado Subtarea 2
- ✅ Validación de email único antes de registro
- ✅ Validación de username único antes de registro
- ✅ Mensajes de error claros si ya existen
- ✅ Evita duplicados en base de datos

### 🧪 Prueba
```bash
# Primer registro - debe funcionar
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'

# Segundo registro con mismo email - debe fallar
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

---

## 📦 SUBTAREA 3: OPCIÓN ROL MIEMBRO/ARTISTA (Manahen)

### Objetivo
Permitir seleccionar entre rol USER (Miembro) o ARTIST (Artista) al registrarse.

### Archivos necesarios

#### 3.1. Crear `UserRole.java` (Enum)
**Ubicación:** `src/main/java/io/audira/community/model/UserRole.java`

```java
package io.audira.community.model;

public enum UserRole {
    USER,    // Miembro regular
    ARTIST,  // Artista
    ADMIN    // Administrador (opcional)
}
```

---

#### 3.2. Actualizar `User.java`
**Agregar campo role:**

```java
package io.audira.community.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    // NUEVO CAMPO
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
```

---

#### 3.3. Actualizar `RegisterRequest.java`
**Agregar campo role:**

```java
package io.audira.community.dto;

import io.audira.community.model.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 100, message = "Password must be at least 6 characters")
    private String password;

    @NotBlank(message = "First name is required")
    private String firstName;

    @NotBlank(message = "Last name is required")
    private String lastName;

    // NUEVO CAMPO
    private UserRole role = UserRole.USER; // Por defecto USER
}
```

---

#### 3.4. Actualizar `UserService.java`
**Agregar manejo de rol:**

```java
package io.audira.community.service;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.model.UserRole;
import io.audira.community.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public User registerUser(RegisterRequest request) {
        // Validaciones
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already in use");
        }
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already in use");
        }

        User user = User.builder()
                .email(request.getEmail())
                .username(request.getUsername())
                .password(request.getPassword())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .role(request.getRole()) // NUEVO: Asignar rol
                .build();

        return userRepository.save(user);
    }
}
```

---

### ✅ Resultado Subtarea 3
- ✅ Campo `role` agregado al modelo User
- ✅ Enum `UserRole` con opciones USER y ARTIST
- ✅ Frontend puede enviar rol en el registro
- ✅ Por defecto se asigna USER si no se especifica

### 🧪 Prueba
```bash
# Registrar como USER (Miembro)
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "member@example.com",
    "username": "member1",
    "password": "password123",
    "firstName": "John",
    "lastName": "Member",
    "role": "USER"
  }'

# Registrar como ARTIST (Artista)
curl -X POST http://localhost:9001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "artist@example.com",
    "username": "artist1",
    "password": "password123",
    "firstName": "Jane",
    "lastName": "Artist",
    "role": "ARTIST"
  }'
```

---

## 📦 SUBTAREA 4: CONFIRMACIÓN POR EMAIL SIMULADA (Eduardo)

### Objetivo
Simular confirmación de email con campo `isVerified` y endpoint de verificación.

### Archivos necesarios

#### 4.1. Actualizar `User.java`
**Agregar campos de verificación:**

```java
package io.audira.community.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    // NUEVOS CAMPOS
    @Column(nullable = false)
    private Boolean isActive;

    @Column(nullable = false)
    private Boolean isVerified; // Estado de verificación del email

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.isActive == null) {
            this.isActive = true;
        }
        if (this.isVerified == null) {
            this.isVerified = false; // Por defecto no verificado
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
```

---

#### 4.2. Actualizar `UserService.java`
**Agregar método de verificación:**

```java
package io.audira.community.service;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private final UserRepository userRepository;

    @Transactional
    public User registerUser(RegisterRequest request) {
        // Validaciones
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already in use");
        }
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already in use");
        }

        User user = User.builder()
                .email(request.getEmail())
                .username(request.getUsername())
                .password(request.getPassword())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .role(request.getRole())
                .isActive(true)
                .isVerified(false) // Por defecto no verificado
                .build();

        user = userRepository.save(user);

        // SIMULAR ENVÍO DE EMAIL
        logger.info("📧 [SIMULADO] Email de verificación enviado a: {}", user.getEmail());
        logger.info("📧 [SIMULADO] Link de verificación: http://localhost:3000/verify-email?userId={}", user.getId());

        return user;
    }

    // NUEVO MÉTODO: Verificar email
    @Transactional
    public User verifyEmail(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getIsVerified()) {
            throw new RuntimeException("Email already verified");
        }

        user.setIsVerified(true);
        user = userRepository.save(user);

        logger.info("✅ Email verified successfully for user: {}", user.getEmail());
        return user;
    }
}
```

---

#### 4.3. Actualizar `AuthController.java`
**Agregar endpoint de verificación:**

```java
package io.audira.community.controller;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@Valid @RequestBody RegisterRequest request) {
        logger.info("Register request received for email: {}", request.getEmail());
        User user = userService.registerUser(request);
        logger.info("User registered successfully: {}", request.getEmail());

        Map<String, Object> response = new HashMap<>();
        response.put("user", user);
        response.put("message", "User registered successfully. Please check your email to verify your account.");

        return ResponseEntity.ok(response);
    }

    // NUEVO ENDPOINT: Verificar email
    @PostMapping("/verify-email/{userId}")
    public ResponseEntity<Map<String, Object>> verifyEmail(@PathVariable Long userId) {
        logger.info("Email verification request received for userId: {}", userId);
        User user = userService.verifyEmail(userId);

        Map<String, Object> response = new HashMap<>();
        response.put("user", user);
        response.put("message", "Email verified successfully!");

        return ResponseEntity.ok(response);
    }
}
```

---

### ✅ Resultado Subtarea 4
- ✅ Campo `isVerified` en modelo User
- ✅ Usuario empieza como no verificado (`isVerified = false`)
- ✅ Log simulado de envío de email
- ✅ Endpoint `/api/auth/verify-email/{userId}` para verificar
- ✅ Mensaje de confirmación al usuario

### 🧪 Prueba
```bash
# 1. Registrar usuario
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

# 2. Verificar email (reemplaza {userId} con el ID del usuario creado)
curl -X POST http://localhost:9001/api/auth/verify-email/1
```

---

## 📝 RESUMEN DE IMPLEMENTACIÓN

### Orden de implementación:
1. **Subtarea 1 (Manahen)**: Estructura básica + endpoint de registro
2. **Subtarea 2 (Eduardo)**: Validaciones de email/username únicos
3. **Subtarea 3 (Manahen)**: Agregar campo rol USER/ARTIST
4. **Subtarea 4 (Eduardo)**: Sistema de verificación de email simulado

### Estado final del backend:
```
✅ POST /api/auth/register       - Registrar usuario
✅ POST /api/auth/verify-email/:id - Verificar email (simulado)
✅ Validaciones de email único
✅ Validaciones de username único
✅ Selección de rol (USER/ARTIST)
✅ Campo isVerified para estado de verificación
✅ Logs de simulación de envío de email
```

---

## 🛠️ DEPENDENCIAS MÍNIMAS (pom.xml)

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

## 🔄 MEJORAS FUTURAS (No incluidas en estas subtareas)

- 🔒 Encriptación de contraseñas con BCrypt
- 🔑 Autenticación con JWT
- 📧 Envío real de emails
- 🔐 Spring Security completo
- 🎨 Campos adicionales para artistas (nombre artístico, bio, etc.)
- 👥 Sistema de followers/following
- 🖼️ Upload de imágenes de perfil

---

## 📞 CONTACTO

Si tienes dudas sobre alguna subtarea, revisa este documento o consulta el código actual en:
- `community-service/src/main/java/io/audira/community/`

---

**Fecha de creación:** 2025-11-03
**Versión:** 1.0
**Autor:** Asistente Claude
