package io.audira.playback.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreatePlaylistRequest {
    private Long userId;
    private String name;
    private String description;
    private String coverImageUrl;
    private Boolean isPublic;
}
