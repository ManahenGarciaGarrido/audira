package io.audira.community.service;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service UserService - Versión SUBTAREA 2
 * Agregadas validaciones de email y username únicos
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public User registerUser(RegisterRequest request) {
        // ========== NUEVAS VALIDACIONES SUBTAREA 2 ==========
        // Validar que el email no esté en uso
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already in use");
        }

        // Validar que el username no esté en uso
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already in use");
        }
        // ====================================================

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
