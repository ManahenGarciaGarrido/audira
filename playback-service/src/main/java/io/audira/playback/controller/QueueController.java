package io.audira.playback.controller;

import io.audira.playback.model.PlayQueue;
import io.audira.playback.service.QueueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/player/queue")
@RequiredArgsConstructor
public class QueueController {

    private final QueueService queueService;

    @GetMapping("/{userId}")
    public ResponseEntity<PlayQueue> getQueue(@PathVariable Long userId) {
        return ResponseEntity.ok(queueService.getUserQueue(userId));
    }

    @PostMapping
    public ResponseEntity<PlayQueue> addToQueue(
            @RequestParam Long userId,
            @RequestParam Long songId) {
        return ResponseEntity.ok(queueService.addToQueue(userId, songId));
    }

    @DeleteMapping
    public ResponseEntity<PlayQueue> removeFromQueue(
            @RequestParam Long userId,
            @RequestParam Long songId) {
        return ResponseEntity.ok(queueService.removeFromQueue(userId, songId));
    }

    @DeleteMapping("/{userId}/clear")
    public ResponseEntity<PlayQueue> clearQueue(@PathVariable Long userId) {
        return ResponseEntity.ok(queueService.clearQueue(userId));
    }

    @PutMapping("/{userId}/index")
    public ResponseEntity<PlayQueue> setCurrentIndex(
            @PathVariable Long userId,
            @RequestParam Integer index) {
        return ResponseEntity.ok(queueService.setCurrentIndex(userId, index));
    }

    @PutMapping("/{userId}/shuffle")
    public ResponseEntity<PlayQueue> shuffleQueue(
            @PathVariable Long userId,
            @RequestParam Boolean shuffle) {
        return ResponseEntity.ok(queueService.shuffleQueue(userId, shuffle));
    }

    @PutMapping("/{userId}/repeat")
    public ResponseEntity<PlayQueue> setRepeatMode(
            @PathVariable Long userId,
            @RequestParam String repeatMode) {
        return ResponseEntity.ok(queueService.setRepeatMode(userId, repeatMode));
    }
}
