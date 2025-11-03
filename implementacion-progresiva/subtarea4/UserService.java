package io.audira.community.service;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service UserService - Versión SUBTAREA 4 (FINAL)
 * Agregado método de verificación de email y logs de simulación
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private final UserRepository userRepository;

    @Transactional
    public User registerUser(RegisterRequest request) {
        // Validaciones de duplicados
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
                .isActive(true)        // Usuario activo desde el registro
                .isVerified(false)     // Pero no verificado hasta confirmar email
                .build();

        user = userRepository.save(user);

        // Log de registro exitoso
        logger.info("New {} registered: {} ({})",
                    user.getRole(),
                    user.getUsername(),
                    user.getEmail());

        // ========== SIMULACIÓN DE ENVÍO DE EMAIL SUBTAREA 4 ==========
        // En producción, aquí llamarías a un EmailService para enviar el email real
        logger.info("📧 [SIMULADO] Email de verificación enviado a: {}", user.getEmail());
        logger.info("📧 [SIMULADO] Link de verificación: http://localhost:3000/verify-email?userId={}", user.getId());
        logger.info("📧 [SIMULADO] Para verificar, llamar a: POST /api/auth/verify-email/{}", user.getId());
        // ============================================================

        return user;
    }

    // ========== NUEVO MÉTODO SUBTAREA 4 ==========
    /**
     * Verifica el email de un usuario
     * @param userId ID del usuario a verificar
     * @return Usuario actualizado con isVerified = true
     * @throws RuntimeException si el usuario no existe o ya está verificado
     */
    @Transactional
    public User verifyEmail(Long userId) {
        // Buscar usuario
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Verificar que no esté ya verificado
        if (user.getIsVerified()) {
            throw new RuntimeException("Email already verified");
        }

        // Marcar como verificado
        user.setIsVerified(true);
        user = userRepository.save(user);

        logger.info("✅ Email verified successfully for user: {} ({})",
                    user.getUsername(),
                    user.getEmail());

        return user;
    }
    // ============================================
}
