package io.audira.communication.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationPriority priority;

    @Column(nullable = false)
    private Boolean isRead;

    @Column
    private Long relatedEntityId;

    @Column
    private String relatedEntityType;

    @Column
    private String actionUrl;

    @Column
    private LocalDateTime readAt;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime expiresAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.isRead == null) {
            this.isRead = false;
        }
        if (this.priority == null) {
            this.priority = NotificationPriority.NORMAL;
        }
    }

    public enum NotificationType {
        NEW_FOLLOWER,
        NEW_COMMENT,
        NEW_LIKE,
        NEW_PURCHASE,
        NEW_RELEASE,
        SYSTEM_ANNOUNCEMENT,
        PROMOTIONAL,
        ARTIST_UPDATE,
        PLAYLIST_UPDATE,
        PAYMENT_CONFIRMATION,
        OTHER
    }

    public enum NotificationPriority {
        LOW,
        NORMAL,
        HIGH,
        URGENT
    }
}
