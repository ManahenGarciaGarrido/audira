package io.audira.catalog.service;

import io.audira.catalog.model.Album;
import io.audira.catalog.model.Song;
import io.audira.catalog.repository.AlbumRepository;
import io.audira.catalog.repository.SongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DiscoveryService {

    private final SongRepository songRepository;
    private final AlbumRepository albumRepository;

    public List<Song> searchSongs(String query) {
        return songRepository.searchByTitleOrArtist(query);
    }

    public List<Album> searchAlbums(String query) {
        return albumRepository.searchByTitleOrArtist(query);
    }

    public List<Song> getTrendingSongs() {
        // Por ahora devuelve las canciones más recientes
        return songRepository.findTop20ByOrderByCreatedAtDesc();
    }

    public List<Album> getTrendingAlbums() {
        // Por ahora devuelve los álbumes más recientes
        return albumRepository.findTop20ByOrderByCreatedAtDesc();
    }

    public List<Song> getRecommendations(Long userId) {
        // Implementación básica: devuelve canciones aleatorias
        // TODO: Implementar algoritmo de recomendación real
        return songRepository.findTop20ByOrderByCreatedAtDesc();
    }
}
