package io.audira.metrics.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "song_metrics")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SongMetrics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long songId;

    @Column(nullable = false)
    private Long totalPlays;

    @Column(nullable = false)
    private Long uniqueListeners;

    @Column(nullable = false)
    private Long totalLikes;

    @Column(nullable = false)
    private Long totalShares;

    @Column(nullable = false)
    private Long totalDownloads;

    @Column(nullable = false)
    private LocalDateTime lastUpdated;

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        this.lastUpdated = LocalDateTime.now();
    }
}
