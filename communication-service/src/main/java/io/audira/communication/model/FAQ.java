package io.audira.communication.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "faqs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FAQ {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String question;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String answer;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FAQCategory category;

    @Column(nullable = false)
    private Integer displayOrder;

    @Column(nullable = false)
    private Boolean isActive;

    @Column(nullable = false)
    private Long viewCount;

    @Column(nullable = false)
    private Long helpfulCount;

    @Column(nullable = false)
    private Long notHelpfulCount;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.isActive == null) {
            this.isActive = true;
        }
        if (this.viewCount == null) {
            this.viewCount = 0L;
        }
        if (this.helpfulCount == null) {
            this.helpfulCount = 0L;
        }
        if (this.notHelpfulCount == null) {
            this.notHelpfulCount = 0L;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public enum FAQCategory {
        ACCOUNT,
        BILLING,
        TECHNICAL,
        ARTISTS,
        CONTENT,
        PRIVACY,
        GENERAL
    }
}
