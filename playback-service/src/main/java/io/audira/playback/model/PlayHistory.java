package io.audira.playback.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "play_history", indexes = {
    @Index(name = "idx_user_played_at", columnList = "userId,playedAt")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlayHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long songId;

    @Column(nullable = false)
    private LocalDateTime playedAt;

    @Column(nullable = false)
    private Double completionPercentage; // 0.0 to 100.0

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.completionPercentage == null) {
            this.completionPercentage = 0.0;
        }
    }
}
