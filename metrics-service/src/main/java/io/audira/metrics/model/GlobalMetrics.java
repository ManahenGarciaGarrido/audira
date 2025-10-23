package io.audira.metrics.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "global_metrics")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GlobalMetrics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long totalUsers;

    @Column(nullable = false)
    private Long totalArtists;

    @Column(nullable = false)
    private Long totalSongs;

    @Column(nullable = false)
    private Long totalAlbums;

    @Column(nullable = false)
    private Long totalPlays;

    @Column(nullable = false)
    private Double totalRevenue;

    @Column(nullable = false)
    private LocalDateTime lastUpdated;

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        this.lastUpdated = LocalDateTime.now();
    }
}
