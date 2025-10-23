package io.audira.catalog.service;

import io.audira.catalog.model.Album;
import io.audira.catalog.repository.AlbumRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AlbumService {

    private final AlbumRepository albumRepository;

    @Transactional
    public Album createAlbum(Album album) {
        return albumRepository.save(album);
    }

    public List<Album> getAllAlbums() {
        return albumRepository.findAll();
    }

    public Optional<Album> getAlbumById(Long id) {
        return albumRepository.findById(id);
    }

    public List<Album> getAlbumsByArtist(Long artistId) {
        return albumRepository.findByArtistId(artistId);
    }

    public List<Album> getAlbumsByGenre(Long genreId) {
        return albumRepository.findByGenreId(genreId);
    }

    public List<Album> searchAlbumsByTitle(String title) {
        return albumRepository.findByTitleContainingIgnoreCase(title);
    }

    public List<Album> getRecentAlbums() {
        return albumRepository.findRecentAlbums();
    }

    @Transactional
    public Album updateAlbum(Long id, Album albumDetails) {
        Album album = albumRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Album not found with id: " + id));

        if (albumDetails.getTitle() != null) {
            album.setTitle(albumDetails.getTitle());
        }

        if (albumDetails.getArtistId() != null) {
            album.setArtistId(albumDetails.getArtistId());
        }

        if (albumDetails.getGenreId() != null) {
            album.setGenreId(albumDetails.getGenreId());
        }

        if (albumDetails.getReleaseDate() != null) {
            album.setReleaseDate(albumDetails.getReleaseDate());
        }

        if (albumDetails.getCoverImageUrl() != null) {
            album.setCoverImageUrl(albumDetails.getCoverImageUrl());
        }

        if (albumDetails.getPrice() != null) {
            album.setPrice(albumDetails.getPrice());
        }

        if (albumDetails.getDescription() != null) {
            album.setDescription(albumDetails.getDescription());
        }

        return albumRepository.save(album);
    }

    @Transactional
    public void deleteAlbum(Long id) {
        if (!albumRepository.existsById(id)) {
            throw new IllegalArgumentException("Album not found with id: " + id);
        }
        albumRepository.deleteById(id);
    }
}
