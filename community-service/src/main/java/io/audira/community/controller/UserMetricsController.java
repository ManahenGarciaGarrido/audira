package io.audira.community.controller;

import io.audira.community.model.UserMetrics;
import io.audira.community.service.MetricsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/metrics/users")
@RequiredArgsConstructor
public class UserMetricsController {

    private final MetricsService metricsService;

    @GetMapping("/{userId}")
    public ResponseEntity<UserMetrics> getUserMetrics(@PathVariable Long userId) {
        return ResponseEntity.ok(metricsService.getUserMetrics(userId));
    }

    @PostMapping("/{userId}/plays")
    public ResponseEntity<UserMetrics> incrementPlays(@PathVariable Long userId) {
        return ResponseEntity.ok(metricsService.incrementUserPlays(userId));
    }

    @PostMapping("/{userId}/listening-time")
    public ResponseEntity<UserMetrics> addListeningTime(
            @PathVariable Long userId,
            @RequestParam Long seconds) {
        return ResponseEntity.ok(metricsService.addListeningTime(userId, seconds));
    }

    @PostMapping("/{userId}/followers/increment")
    public ResponseEntity<UserMetrics> incrementFollowers(@PathVariable Long userId) {
        return ResponseEntity.ok(metricsService.incrementFollowers(userId));
    }

    @PostMapping("/{userId}/followers/decrement")
    public ResponseEntity<UserMetrics> decrementFollowers(@PathVariable Long userId) {
        return ResponseEntity.ok(metricsService.decrementFollowers(userId));
    }

    @PostMapping("/{userId}/following/increment")
    public ResponseEntity<UserMetrics> incrementFollowing(@PathVariable Long userId) {
        return ResponseEntity.ok(metricsService.incrementFollowing(userId));
    }

    @PostMapping("/{userId}/following/decrement")
    public ResponseEntity<UserMetrics> decrementFollowing(@PathVariable Long userId) {
        return ResponseEntity.ok(metricsService.decrementFollowing(userId));
    }

    @PostMapping("/{userId}/purchases")
    public ResponseEntity<UserMetrics> incrementPurchases(@PathVariable Long userId) {
        return ResponseEntity.ok(metricsService.incrementPurchases(userId));
    }
}
