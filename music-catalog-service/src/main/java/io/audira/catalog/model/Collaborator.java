package io.audira.catalog.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "collaborators")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Collaborator {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "song_id", nullable = false)
    private Long songId;

    @Column(name = "artist_id", nullable = false)
    private Long artistId;

    @Column(name = "artist_name", nullable = false)
    private String artistName;

    @Enumerated(EnumType.STRING)
    @Column(name = "collaboration_type", nullable = false)
    private CollaborationType collaborationType;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public enum CollaborationType {
        MAIN_ARTIST,
        FEATURED_ARTIST,
        PRODUCER,
        COMPOSER,
        LYRICIST,
        VOCALIST,
        GUITARIST,
        BASSIST,
        DRUMMER,
        PIANIST,
        MIXING_ENGINEER,
        MASTERING_ENGINEER,
        OTHER
    }
}
