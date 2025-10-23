package io.audira.community.repository;

import io.audira.community.model.SongMetrics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface SongMetricsRepository extends JpaRepository<SongMetrics, Long> {
    Optional<SongMetrics> findBySongId(Long songId);
}
