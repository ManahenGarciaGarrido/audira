package io.audira.playlist.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddSongRequest {

    @NotNull(message = "Song ID is required")
    private Long songId;

    private Integer position; // Optional - if null, add to end
}
