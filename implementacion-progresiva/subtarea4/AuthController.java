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

/**
 * Controller AuthController - Versión SUBTAREA 4 (FINAL)
 * Agregado endpoint de verificación de email
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    private final UserService userService;

    /**
     * Registra un nuevo usuario
     * Retorna el usuario creado y un mensaje informativo
     */
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@Valid @RequestBody RegisterRequest request) {
        logger.info("Register request received for email: {}", request.getEmail());
        User user = userService.registerUser(request);
        logger.info("User registered successfully: {}", request.getEmail());

        // Preparar respuesta con mensaje informativo
        Map<String, Object> response = new HashMap<>();
        response.put("user", user);
        response.put("message", "User registered successfully. Please check your email to verify your account.");

        return ResponseEntity.ok(response);
    }

    // ========== NUEVO ENDPOINT SUBTAREA 4 ==========
    /**
     * Verifica el email de un usuario
     * En producción, esto debería validar un token único en lugar de userId
     *
     * @param userId ID del usuario a verificar
     * @return Usuario actualizado con isVerified = true
     */
    @PostMapping("/verify-email/{userId}")
    public ResponseEntity<Map<String, Object>> verifyEmail(@PathVariable Long userId) {
        logger.info("Email verification request received for userId: {}", userId);

        try {
            User user = userService.verifyEmail(userId);

            Map<String, Object> response = new HashMap<>();
            response.put("user", user);
            response.put("message", "Email verified successfully!");

            logger.info("Email verified successfully for userId: {}", userId);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            logger.error("Error verifying email for userId {}: {}", userId, e.getMessage());
            throw e;
        }
    }
    // ==============================================
}
