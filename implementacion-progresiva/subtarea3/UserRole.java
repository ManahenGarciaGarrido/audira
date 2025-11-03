package io.audira.community.model;

/**
 * Enum UserRole - NUEVO en SUBTAREA 3
 * Define los roles disponibles para los usuarios
 */
public enum UserRole {
    /**
     * Usuario regular/miembro
     * Puede escuchar música, crear playlists, seguir artistas, etc.
     */
    USER,

    /**
     * Usuario artista
     * Además de las funciones de USER, puede subir música, ver estadísticas, etc.
     */
    ARTIST,

    /**
     * Usuario administrador
     * Tiene permisos especiales de moderación y gestión
     */
    ADMIN
}
