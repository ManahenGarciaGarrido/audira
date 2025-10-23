package io.audira.playback.repository;

import io.audira.playback.model.PlaylistSong;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface PlaylistSongRepository extends JpaRepository<PlaylistSong, Long> {

    List<PlaylistSong> findByPlaylistIdOrderByPositionAsc(Long playlistId);

    @Transactional
    void deleteByPlaylistId(Long playlistId);

    @Transactional
    void deleteByPlaylistIdAndSongId(Long playlistId, Long songId);
}
