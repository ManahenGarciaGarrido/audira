package io.audira.community.controller;

import io.audira.community.model.ArtistMetrics;
import io.audira.community.service.MetricsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/metrics/artists")
@RequiredArgsConstructor
public class ArtistMetricsController {

    private final MetricsService metricsService;

    @GetMapping("/{artistId}")
    public ResponseEntity<ArtistMetrics> getArtistMetrics(@PathVariable Long artistId) {
        return ResponseEntity.ok(metricsService.getArtistMetrics(artistId));
    }

    @PostMapping("/{artistId}/plays")
    public ResponseEntity<ArtistMetrics> incrementPlays(@PathVariable Long artistId) {
        return ResponseEntity.ok(metricsService.incrementArtistPlays(artistId));
    }

    @PostMapping("/{artistId}/listeners")
    public ResponseEntity<ArtistMetrics> incrementListeners(@PathVariable Long artistId) {
        return ResponseEntity.ok(metricsService.incrementArtistListeners(artistId));
    }

    @PostMapping("/{artistId}/followers/increment")
    public ResponseEntity<ArtistMetrics> incrementFollowers(@PathVariable Long artistId) {
        return ResponseEntity.ok(metricsService.incrementArtistFollowers(artistId));
    }

    @PostMapping("/{artistId}/followers/decrement")
    public ResponseEntity<ArtistMetrics> decrementFollowers(@PathVariable Long artistId) {
        return ResponseEntity.ok(metricsService.decrementArtistFollowers(artistId));
    }

    @PostMapping("/{artistId}/sales")
    public ResponseEntity<ArtistMetrics> addSale(
            @PathVariable Long artistId,
            @RequestParam Double amount) {
        return ResponseEntity.ok(metricsService.addArtistSale(artistId, amount));
    }
}
