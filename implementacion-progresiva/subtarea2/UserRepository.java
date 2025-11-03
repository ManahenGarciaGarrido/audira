package io.audira.community.repository;

import io.audira.community.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

/**
 * Repository UserRepository - Versión SUBTAREA 2
 * Agregados métodos de validación de existencia
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);

    // ========== NUEVOS MÉTODOS SUBTAREA 2 ==========
    /**
     * Verifica si existe un usuario con el email dado
     * @param email Email a verificar
     * @return true si existe, false si no
     */
    Boolean existsByEmail(String email);

    /**
     * Verifica si existe un usuario con el username dado
     * @param username Username a verificar
     * @return true si existe, false si no
     */
    Boolean existsByUsername(String username);
}
