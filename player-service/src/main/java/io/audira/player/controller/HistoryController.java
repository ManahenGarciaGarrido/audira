package io.audira.player.controller;

import io.audira.player.model.PlayHistory;
import io.audira.player.service.HistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/player/history")
@RequiredArgsConstructor
public class HistoryController {

    private final HistoryService historyService;

    @PostMapping
    public ResponseEntity<PlayHistory> recordPlay(
            @RequestParam Long userId,
            @RequestParam Long songId,
            @RequestParam Integer completionPercentage) {
        return ResponseEntity.ok(historyService.recordPlay(userId, songId, completionPercentage));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<PlayHistory>> getUserHistory(@PathVariable Long userId) {
        return ResponseEntity.ok(historyService.getUserHistory(userId));
    }

    @GetMapping("/user/{userId}/recent")
    public ResponseEntity<List<PlayHistory>> getRecentHistory(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "20") Integer limit) {
        return ResponseEntity.ok(historyService.getRecentHistory(userId, limit));
    }

    @DeleteMapping("/user/{userId}")
    public ResponseEntity<Void> clearHistory(@PathVariable Long userId) {
        historyService.clearHistory(userId);
        return ResponseEntity.noContent().build();
    }
}
