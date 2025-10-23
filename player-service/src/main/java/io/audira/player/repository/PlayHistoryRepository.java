package io.audira.player.repository;

import io.audira.player.model.PlayHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PlayHistoryRepository extends JpaRepository<PlayHistory, Long> {
    List<PlayHistory> findByUserIdOrderByPlayedAtDesc(Long userId);
    List<PlayHistory> findByUserIdAndSongIdOrderByPlayedAtDesc(Long userId, Long songId);
    List<PlayHistory> findBySongId(Long songId);
    List<PlayHistory> findByUserIdAndPlayedAtBetweenOrderByPlayedAtDesc(
        Long userId, LocalDateTime start, LocalDateTime end
    );

    @Query("SELECT ph FROM PlayHistory ph WHERE ph.userId = ?1 AND ph.completionPercentage >= ?2 ORDER BY ph.playedAt DESC")
    List<PlayHistory> findByUserIdAndMinCompletionPercentage(Long userId, Double minPercentage);

    @Query("SELECT COUNT(ph) FROM PlayHistory ph WHERE ph.userId = ?1")
    Long countByUserId(Long userId);

    void deleteByUserId(Long userId);
    void deleteByUserIdAndPlayedAtBefore(Long userId, LocalDateTime before);
}
