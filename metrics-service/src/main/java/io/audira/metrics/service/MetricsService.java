package io.audira.metrics.service;

import io.audira.metrics.model.*;
import io.audira.metrics.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MetricsService {

    private final UserMetricsRepository userMetricsRepository;
    private final ArtistMetricsRepository artistMetricsRepository;
    private final SongMetricsRepository songMetricsRepository;
    private final GlobalMetricsRepository globalMetricsRepository;

    // User Metrics
    public UserMetrics getUserMetrics(Long userId) {
        return userMetricsRepository.findByUserId(userId)
                .orElseGet(() -> createDefaultUserMetrics(userId));
    }

    @Transactional
    public UserMetrics incrementUserPlays(Long userId) {
        UserMetrics metrics = getUserMetrics(userId);
        metrics.setTotalPlays(metrics.getTotalPlays() + 1);
        return userMetricsRepository.save(metrics);
    }

    @Transactional
    public UserMetrics addListeningTime(Long userId, Long seconds) {
        UserMetrics metrics = getUserMetrics(userId);
        metrics.setTotalListeningTime(metrics.getTotalListeningTime() + seconds);
        return userMetricsRepository.save(metrics);
    }

    @Transactional
    public UserMetrics incrementFollowers(Long userId) {
        UserMetrics metrics = getUserMetrics(userId);
        metrics.setTotalFollowers(metrics.getTotalFollowers() + 1);
        return userMetricsRepository.save(metrics);
    }

    @Transactional
    public UserMetrics decrementFollowers(Long userId) {
        UserMetrics metrics = getUserMetrics(userId);
        if (metrics.getTotalFollowers() > 0) {
            metrics.setTotalFollowers(metrics.getTotalFollowers() - 1);
        }
        return userMetricsRepository.save(metrics);
    }

    @Transactional
    public UserMetrics incrementFollowing(Long userId) {
        UserMetrics metrics = getUserMetrics(userId);
        metrics.setTotalFollowing(metrics.getTotalFollowing() + 1);
        return userMetricsRepository.save(metrics);
    }

    @Transactional
    public UserMetrics decrementFollowing(Long userId) {
        UserMetrics metrics = getUserMetrics(userId);
        if (metrics.getTotalFollowing() > 0) {
            metrics.setTotalFollowing(metrics.getTotalFollowing() - 1);
        }
        return userMetricsRepository.save(metrics);
    }

    @Transactional
    public UserMetrics incrementPurchases(Long userId) {
        UserMetrics metrics = getUserMetrics(userId);
        metrics.setTotalPurchases(metrics.getTotalPurchases() + 1);
        return userMetricsRepository.save(metrics);
    }

    private UserMetrics createDefaultUserMetrics(Long userId) {
        return UserMetrics.builder()
                .userId(userId)
                .totalPlays(0L)
                .totalListeningTime(0L)
                .totalFollowers(0L)
                .totalFollowing(0L)
                .totalPurchases(0L)
                .build();
    }

    // Artist Metrics
    public ArtistMetrics getArtistMetrics(Long artistId) {
        return artistMetricsRepository.findByArtistId(artistId)
                .orElseGet(() -> createDefaultArtistMetrics(artistId));
    }

    @Transactional
    public ArtistMetrics incrementArtistPlays(Long artistId) {
        ArtistMetrics metrics = getArtistMetrics(artistId);
        metrics.setTotalPlays(metrics.getTotalPlays() + 1);
        return artistMetricsRepository.save(metrics);
    }

    @Transactional
    public ArtistMetrics incrementArtistListeners(Long artistId) {
        ArtistMetrics metrics = getArtistMetrics(artistId);
        metrics.setTotalListeners(metrics.getTotalListeners() + 1);
        return artistMetricsRepository.save(metrics);
    }

    @Transactional
    public ArtistMetrics incrementArtistFollowers(Long artistId) {
        ArtistMetrics metrics = getArtistMetrics(artistId);
        metrics.setTotalFollowers(metrics.getTotalFollowers() + 1);
        return artistMetricsRepository.save(metrics);
    }

    @Transactional
    public ArtistMetrics decrementArtistFollowers(Long artistId) {
        ArtistMetrics metrics = getArtistMetrics(artistId);
        if (metrics.getTotalFollowers() > 0) {
            metrics.setTotalFollowers(metrics.getTotalFollowers() - 1);
        }
        return artistMetricsRepository.save(metrics);
    }

    @Transactional
    public ArtistMetrics addArtistSale(Long artistId, Double amount) {
        ArtistMetrics metrics = getArtistMetrics(artistId);
        metrics.setTotalSales(metrics.getTotalSales() + 1);
        metrics.setTotalRevenue(metrics.getTotalRevenue() + amount);
        return artistMetricsRepository.save(metrics);
    }

    private ArtistMetrics createDefaultArtistMetrics(Long artistId) {
        return ArtistMetrics.builder()
                .artistId(artistId)
                .totalPlays(0L)
                .totalListeners(0L)
                .totalFollowers(0L)
                .totalSales(0L)
                .totalRevenue(0.0)
                .build();
    }

    // Song Metrics
    public SongMetrics getSongMetrics(Long songId) {
        return songMetricsRepository.findBySongId(songId)
                .orElseGet(() -> createDefaultSongMetrics(songId));
    }

    @Transactional
    public SongMetrics incrementSongPlays(Long songId) {
        SongMetrics metrics = getSongMetrics(songId);
        metrics.setTotalPlays(metrics.getTotalPlays() + 1);
        return songMetricsRepository.save(metrics);
    }

    @Transactional
    public SongMetrics incrementUniqueListeners(Long songId) {
        SongMetrics metrics = getSongMetrics(songId);
        metrics.setUniqueListeners(metrics.getUniqueListeners() + 1);
        return songMetricsRepository.save(metrics);
    }

    @Transactional
    public SongMetrics incrementLikes(Long songId) {
        SongMetrics metrics = getSongMetrics(songId);
        metrics.setTotalLikes(metrics.getTotalLikes() + 1);
        return songMetricsRepository.save(metrics);
    }

    @Transactional
    public SongMetrics decrementLikes(Long songId) {
        SongMetrics metrics = getSongMetrics(songId);
        if (metrics.getTotalLikes() > 0) {
            metrics.setTotalLikes(metrics.getTotalLikes() - 1);
        }
        return songMetricsRepository.save(metrics);
    }

    @Transactional
    public SongMetrics incrementShares(Long songId) {
        SongMetrics metrics = getSongMetrics(songId);
        metrics.setTotalShares(metrics.getTotalShares() + 1);
        return songMetricsRepository.save(metrics);
    }

    @Transactional
    public SongMetrics incrementDownloads(Long songId) {
        SongMetrics metrics = getSongMetrics(songId);
        metrics.setTotalDownloads(metrics.getTotalDownloads() + 1);
        return songMetricsRepository.save(metrics);
    }

    private SongMetrics createDefaultSongMetrics(Long songId) {
        return SongMetrics.builder()
                .songId(songId)
                .totalPlays(0L)
                .uniqueListeners(0L)
                .totalLikes(0L)
                .totalShares(0L)
                .totalDownloads(0L)
                .build();
    }

    // Global Metrics
    public GlobalMetrics getGlobalMetrics() {
        return globalMetricsRepository.findAll().stream()
                .findFirst()
                .orElseGet(this::createDefaultGlobalMetrics);
    }

    @Transactional
    public GlobalMetrics updateGlobalMetrics(GlobalMetrics metrics) {
        GlobalMetrics existing = getGlobalMetrics();
        existing.setTotalUsers(metrics.getTotalUsers());
        existing.setTotalArtists(metrics.getTotalArtists());
        existing.setTotalSongs(metrics.getTotalSongs());
        existing.setTotalAlbums(metrics.getTotalAlbums());
        existing.setTotalPlays(metrics.getTotalPlays());
        existing.setTotalRevenue(metrics.getTotalRevenue());
        return globalMetricsRepository.save(existing);
    }

    private GlobalMetrics createDefaultGlobalMetrics() {
        return globalMetricsRepository.save(GlobalMetrics.builder()
                .totalUsers(0L)
                .totalArtists(0L)
                .totalSongs(0L)
                .totalAlbums(0L)
                .totalPlays(0L)
                .totalRevenue(0.0)
                .build());
    }
}
