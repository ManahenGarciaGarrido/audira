package io.audira.metrics.repository;

import io.audira.metrics.model.GlobalMetrics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GlobalMetricsRepository extends JpaRepository<GlobalMetrics, Long> {
}
