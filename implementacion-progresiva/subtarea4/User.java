package io.audira.community.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

/**
 * Entidad User - Versión SUBTAREA 4 (FINAL)
 * Agregados campos isActive e isVerified para gestión de cuentas
 */
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

    // ========== NUEVOS CAMPOS SUBTAREA 4 ==========
    /**
     * Indica si el usuario está activo (puede iniciar sesión)
     * Por defecto es true al registrarse
     */
    @Column(nullable = false)
    private Boolean isActive;

    /**
     * Indica si el email del usuario ha sido verificado
     * Por defecto es false, se cambia a true al verificar
     */
    @Column(nullable = false)
    private Boolean isVerified;
    // ==============================================

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();

        // ========== INICIALIZACIÓN SUBTAREA 4 ==========
        // Si no se especifica, el usuario está activo por defecto
        if (this.isActive == null) {
            this.isActive = true;
        }

        // Si no se especifica, el usuario NO está verificado por defecto
        if (this.isVerified == null) {
            this.isVerified = false;
        }
        // ==============================================
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
