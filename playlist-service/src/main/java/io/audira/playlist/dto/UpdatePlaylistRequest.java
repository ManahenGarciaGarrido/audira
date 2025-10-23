package io.audira.playlist.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePlaylistRequest {
    private String name;
    private String description;
    private String coverImageUrl;
    private Boolean isPublic;
}
