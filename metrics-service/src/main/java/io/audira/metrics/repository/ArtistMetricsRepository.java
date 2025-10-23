package io.audira.metrics.repository;

import io.audira.metrics.model.ArtistMetrics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface ArtistMetricsRepository extends JpaRepository<ArtistMetrics, Long> {
    Optional<ArtistMetrics> findByArtistId(Long artistId);
}
