package io.audira.playback.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlaylistSongDTO {
    private Long id;
    private Long playlistId;
    private Long songId;
    private int position;
    private LocalDateTime addedAt;
}
