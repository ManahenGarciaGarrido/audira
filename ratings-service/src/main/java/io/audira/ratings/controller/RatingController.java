package io.audira.ratings.controller;

import io.audira.ratings.model.EntityType;
import io.audira.ratings.model.Rating;
import io.audira.ratings.service.RatingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ratings")
@RequiredArgsConstructor
public class RatingController {

    private final RatingService ratingService;

    @PostMapping
    public ResponseEntity<Rating> createOrUpdateRating(
            @RequestParam Long userId,
            @RequestParam EntityType entityType,
            @RequestParam Long entityId,
            @RequestParam Integer rating) {
        return ResponseEntity.ok(ratingService.createOrUpdateRating(userId, entityType, entityId, rating));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Rating>> getUserRatings(@PathVariable Long userId) {
        return ResponseEntity.ok(ratingService.getUserRatings(userId));
    }

    @GetMapping("/entity/{entityType}/{entityId}")
    public ResponseEntity<List<Rating>> getEntityRatings(
            @PathVariable EntityType entityType,
            @PathVariable Long entityId) {
        return ResponseEntity.ok(ratingService.getEntityRatings(entityType, entityId));
    }

    @GetMapping("/entity/{entityType}/{entityId}/average")
    public ResponseEntity<Map<String, Object>> getEntityRatingStats(
            @PathVariable EntityType entityType,
            @PathVariable Long entityId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("average", ratingService.getAverageRating(entityType, entityId));
        stats.put("count", ratingService.getRatingCount(entityType, entityId));
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/user/{userId}/entity/{entityType}/{entityId}")
    public ResponseEntity<Rating> getUserRating(
            @PathVariable Long userId,
            @PathVariable EntityType entityType,
            @PathVariable Long entityId) {
        return ratingService.getUserRating(userId, entityType, entityId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{ratingId}")
    public ResponseEntity<Void> deleteRating(@PathVariable Long ratingId) {
        ratingService.deleteRating(ratingId);
        return ResponseEntity.noContent().build();
    }
}
