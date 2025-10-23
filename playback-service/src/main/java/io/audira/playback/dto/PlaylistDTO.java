package io.audira.playback.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlaylistDTO {
    private Long id;
    private Long userId;
    private String name;
    private String description;
    private String coverImageUrl;
    private Boolean isPublic;
    private List<Long> songIds;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
