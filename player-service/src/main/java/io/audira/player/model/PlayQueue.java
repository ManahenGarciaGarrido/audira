package io.audira.player.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "play_queues")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlayQueue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long userId;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "queue_songs", joinColumns = @JoinColumn(name = "queue_id"))
    @Column(name = "song_id")
    @OrderColumn(name = "position")
    private List<Long> songIds = new ArrayList<>();

    @Column(nullable = false)
    private Integer currentIndex;

    @Column(nullable = false)
    private Boolean shuffle;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RepeatMode repeatMode;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.currentIndex == null) {
            this.currentIndex = 0;
        }
        if (this.shuffle == null) {
            this.shuffle = false;
        }
        if (this.repeatMode == null) {
            this.repeatMode = RepeatMode.OFF;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
