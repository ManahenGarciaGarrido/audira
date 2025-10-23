package io.audira.playback.service;

import io.audira.playback.model.PlayHistory;
import io.audira.playback.repository.PlayHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HistoryService {

    private final PlayHistoryRepository playHistoryRepository;

    @Transactional
    public PlayHistory recordPlay(Long userId, Long songId, Integer completionPercentage) {
        PlayHistory history = PlayHistory.builder()
                .userId(userId)
                .songId(songId)
                .playedAt(LocalDateTime.now())
                .completionPercentage(completionPercentage.doubleValue())
                .build();
        return playHistoryRepository.save(history);
    }

    public List<PlayHistory> getUserHistory(Long userId) {
        return playHistoryRepository.findByUserIdOrderByPlayedAtDesc(userId);
    }

    public List<PlayHistory> getRecentHistory(Long userId, Integer limit) {
        return playHistoryRepository.findTop20ByUserIdOrderByPlayedAtDesc(userId);
    }

    @Transactional
    public void clearHistory(Long userId) {
        playHistoryRepository.deleteByUserId(userId);
    }
}
