package io.audira.community.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "artist_metrics")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ArtistMetrics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long artistId;

    @Column(nullable = false)
    private Long totalPlays;

    @Column(nullable = false)
    private Long totalListeners;

    @Column(nullable = false)
    private Long totalFollowers;

    @Column(nullable = false)
    private Long totalSales;

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
