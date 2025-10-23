package io.audira.player.repository;

import io.audira.player.model.PlaybackSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface PlaybackSessionRepository extends JpaRepository<PlaybackSession, Long> {
    Optional<PlaybackSession> findByUserIdAndIsPlaying(Long userId, Boolean isPlaying);
    Optional<PlaybackSession> findTopByUserIdOrderByCreatedAtDesc(Long userId);
    List<PlaybackSession> findByUserId(Long userId);
    List<PlaybackSession> findBySongId(Long songId);
    List<PlaybackSession> findByUserIdAndSongId(Long userId, Long songId);
    void deleteByUserId(Long userId);
}
