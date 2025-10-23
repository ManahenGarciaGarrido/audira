package io.audira.player.repository;

import io.audira.player.model.PlayQueue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface PlayQueueRepository extends JpaRepository<PlayQueue, Long> {
    Optional<PlayQueue> findByUserId(Long userId);
    Boolean existsByUserId(Long userId);
    void deleteByUserId(Long userId);
}
