package io.audira.playlist.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreatePlaylistRequest {

    @NotNull(message = "User ID is required")
    private Long userId;

    @NotBlank(message = "Playlist name is required")
    private String name;

    private String description;
    private String coverImageUrl;

    @NotNull(message = "isPublic field is required")
    private Boolean isPublic;
}
