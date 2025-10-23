package io.audira.playback.controller;

import io.audira.playback.model.PlaybackSession;
import io.audira.playback.service.PlaybackService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/playback")
@RequiredArgsConstructor
public class PlaybackController {

    private final PlaybackService playbackService;

    @PostMapping("/play")
    public ResponseEntity<PlaybackSession> play(
            @RequestParam Long userId,
            @RequestParam Long songId,
            @RequestParam Integer duration) {
        return ResponseEntity.ok(playbackService.startPlayback(userId, songId, duration));
    }

    @PutMapping("/{sessionId}/pause")
    public ResponseEntity<PlaybackSession> pause(@PathVariable Long sessionId) {
        return ResponseEntity.ok(playbackService.pausePlayback(sessionId));
    }

    @PutMapping("/{sessionId}/resume")
    public ResponseEntity<PlaybackSession> resume(@PathVariable Long sessionId) {
        return ResponseEntity.ok(playbackService.resumePlayback(sessionId));
    }

    @PutMapping("/{sessionId}/seek")
    public ResponseEntity<PlaybackSession> seek(
            @PathVariable Long sessionId,
            @RequestParam Integer time) {
        return ResponseEntity.ok(playbackService.seek(sessionId, time));
    }

    @DeleteMapping("/{sessionId}")
    public ResponseEntity<Void> stop(@PathVariable Long sessionId) {
        playbackService.stopPlayback(sessionId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/current/{userId}")
    public ResponseEntity<PlaybackSession> getCurrentSession(@PathVariable Long userId) {
        PlaybackSession session = playbackService.getCurrentSession(userId);
        if (session == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(session);
    }

    @GetMapping("/sessions/{userId}")
    public ResponseEntity<List<PlaybackSession>> getUserSessions(@PathVariable Long userId) {
        return ResponseEntity.ok(playbackService.getUserSessions(userId));
    }
}
