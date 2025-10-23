package io.audira.playback.service;

import io.audira.playback.model.PlayQueue;
import io.audira.playback.repository.PlayQueueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QueueService {

    private final PlayQueueRepository playQueueRepository;

    public PlayQueue getUserQueue(Long userId) {
        return playQueueRepository.findByUserId(userId)
                .orElseGet(() -> createDefaultQueue(userId));
    }

    @Transactional
    public PlayQueue addToQueue(Long userId, Long songId) {
        PlayQueue queue = getUserQueue(userId);
        List<Long> songIds = new ArrayList<>(queue.getSongIds());
        songIds.add(songId);
        queue.setSongIds(songIds);
        return playQueueRepository.save(queue);
    }

    @Transactional
    public PlayQueue removeFromQueue(Long userId, Long songId) {
        PlayQueue queue = getUserQueue(userId);
        List<Long> songIds = new ArrayList<>(queue.getSongIds());
        songIds.remove(songId);
        queue.setSongIds(songIds);
        return playQueueRepository.save(queue);
    }

    @Transactional
    public PlayQueue clearQueue(Long userId) {
        PlayQueue queue = getUserQueue(userId);
        queue.setSongIds(new ArrayList<>());
        queue.setCurrentIndex(0);
        return playQueueRepository.save(queue);
    }

    @Transactional
    public PlayQueue setCurrentIndex(Long userId, Integer index) {
        PlayQueue queue = getUserQueue(userId);
        queue.setCurrentIndex(index);
        return playQueueRepository.save(queue);
    }

    @Transactional
    public PlayQueue shuffleQueue(Long userId, Boolean shuffle) {
        PlayQueue queue = getUserQueue(userId);
        queue.setShuffle(shuffle);
        if (shuffle) {
            List<Long> songIds = new ArrayList<>(queue.getSongIds());
            Collections.shuffle(songIds);
            queue.setSongIds(songIds);
        }
        return playQueueRepository.save(queue);
    }

    @Transactional
    public PlayQueue setRepeatMode(Long userId, String repeatMode) {
        PlayQueue queue = getUserQueue(userId);
        queue.setRepeatMode(io.audira.player.model.RepeatMode.valueOf(repeatMode.toUpperCase()));
        return playQueueRepository.save(queue);
    }

    private PlayQueue createDefaultQueue(Long userId) {
        PlayQueue queue = PlayQueue.builder()
                .userId(userId)
                .songIds(new ArrayList<>())
                .currentIndex(0)
                .shuffle(false)
                .repeatMode(io.audira.player.model.RepeatMode.OFF)
                .build();
        return playQueueRepository.save(queue);
    }
}
