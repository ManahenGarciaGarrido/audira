package io.audira.metrics.controller;

import io.audira.metrics.model.GlobalMetrics;
import io.audira.metrics.service.MetricsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/metrics/global")
@RequiredArgsConstructor
public class GlobalMetricsController {

    private final MetricsService metricsService;

    @GetMapping
    public ResponseEntity<GlobalMetrics> getGlobalMetrics() {
        return ResponseEntity.ok(metricsService.getGlobalMetrics());
    }

    @PutMapping
    public ResponseEntity<GlobalMetrics> updateGlobalMetrics(@RequestBody GlobalMetrics metrics) {
        return ResponseEntity.ok(metricsService.updateGlobalMetrics(metrics));
    }
}
