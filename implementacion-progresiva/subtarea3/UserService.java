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
 * Service UserService - Versión SUBTAREA 3
 * Agregado manejo de roles en el registro
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
                .role(request.getRole()) // ========== NUEVO: Asignar rol ==========
                .build();

        user = userRepository.save(user);

        // Log para ver qué tipo de usuario se registró
        logger.info("New {} registered: {} ({})",
                    user.getRole(),
                    user.getUsername(),
                    user.getEmail());

        return user;
    }
}
