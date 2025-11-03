package io.audira.community.service;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service UserService - Versión SUBTAREA 1
 * Lógica de negocio para usuarios (versión básica)
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public User registerUser(RegisterRequest request) {
        // Por ahora, guardamos directamente sin validaciones adicionales
        // La contraseña se guarda en texto plano (se mejorará después)
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
