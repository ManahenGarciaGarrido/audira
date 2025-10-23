package io.audira.community.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_metrics")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserMetrics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long userId;

    @Column(nullable = false)
    private Long totalPlays;

    @Column(nullable = false)
    private Long totalListeningTime; // in seconds

    @Column(nullable = false)
    private Long totalFollowers;

    @Column(nullable = false)
    private Long totalFollowing;

    @Column(nullable = false)
    private Long totalPurchases;

    @Column(nullable = false)
    private LocalDateTime lastUpdated;

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        this.lastUpdated = LocalDateTime.now();
    }
}
