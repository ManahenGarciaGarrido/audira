package io.audira.metrics.controller;

import io.audira.metrics.model.SongMetrics;
import io.audira.metrics.service.MetricsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/metrics/songs")
@RequiredArgsConstructor
public class SongMetricsController {

    private final MetricsService metricsService;

    @GetMapping("/{songId}")
    public ResponseEntity<SongMetrics> getSongMetrics(@PathVariable Long songId) {
        return ResponseEntity.ok(metricsService.getSongMetrics(songId));
    }

    @PostMapping("/{songId}/plays")
    public ResponseEntity<SongMetrics> incrementPlays(@PathVariable Long songId) {
        return ResponseEntity.ok(metricsService.incrementSongPlays(songId));
    }

    @PostMapping("/{songId}/listeners")
    public ResponseEntity<SongMetrics> incrementListeners(@PathVariable Long songId) {
        return ResponseEntity.ok(metricsService.incrementUniqueListeners(songId));
    }

    @PostMapping("/{songId}/likes")
    public ResponseEntity<SongMetrics> incrementLikes(@PathVariable Long songId) {
        return ResponseEntity.ok(metricsService.incrementLikes(songId));
    }

    @DeleteMapping("/{songId}/likes")
    public ResponseEntity<SongMetrics> decrementLikes(@PathVariable Long songId) {
        return ResponseEntity.ok(metricsService.decrementLikes(songId));
    }

    @PostMapping("/{songId}/shares")
    public ResponseEntity<SongMetrics> incrementShares(@PathVariable Long songId) {
        return ResponseEntity.ok(metricsService.incrementShares(songId));
    }

    @PostMapping("/{songId}/downloads")
    public ResponseEntity<SongMetrics> incrementDownloads(@PathVariable Long songId) {
        return ResponseEntity.ok(metricsService.incrementDownloads(songId));
    }
}
