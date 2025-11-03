package io.audira.community.dto;

import io.audira.community.model.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO RegisterRequest - Versión SUBTAREA 3
 * Agregado campo role con valor por defecto USER
 */
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

    // ========== NUEVO CAMPO SUBTAREA 3 ==========
    /**
     * Rol del usuario a registrar
     * Valores válidos: USER, ARTIST, ADMIN
     * Por defecto es USER si no se especifica
     */
    private UserRole role = UserRole.USER;
    // ============================================
}
