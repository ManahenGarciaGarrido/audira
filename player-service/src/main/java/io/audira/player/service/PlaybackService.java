package io.audira.player.service;

import io.audira.player.model.PlaybackSession;
import io.audira.player.repository.PlaybackSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaybackService {

    private final PlaybackSessionRepository playbackSessionRepository;

    @Transactional
    public PlaybackSession startPlayback(Long userId, Long songId, Integer duration) {
        PlaybackSession session = PlaybackSession.builder()
                .userId(userId)
                .songId(songId)
                .startTime(LocalDateTime.now())
                .currentTime(0)
                .duration(duration)
                .isPlaying(true)
                .build();
        return playbackSessionRepository.save(session);
    }

    @Transactional
    public PlaybackSession pausePlayback(Long sessionId) {
        PlaybackSession session = playbackSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Playback session not found"));
        session.setIsPlaying(false);
        return playbackSessionRepository.save(session);
    }

    @Transactional
    public PlaybackSession resumePlayback(Long sessionId) {
        PlaybackSession session = playbackSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Playback session not found"));
        session.setIsPlaying(true);
        return playbackSessionRepository.save(session);
    }

    @Transactional
    public PlaybackSession seek(Long sessionId, Integer timeInSeconds) {
        PlaybackSession session = playbackSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Playback session not found"));
        session.setCurrentTime(timeInSeconds);
        return playbackSessionRepository.save(session);
    }

    @Transactional
    public void stopPlayback(Long sessionId) {
        playbackSessionRepository.deleteById(sessionId);
    }

    public PlaybackSession getCurrentSession(Long userId) {
        return playbackSessionRepository.findByUserIdAndIsPlayingTrue(userId).orElse(null);
    }

    public List<PlaybackSession> getUserSessions(Long userId) {
        return playbackSessionRepository.findByUserIdOrderByStartTimeDesc(userId);
    }
}
