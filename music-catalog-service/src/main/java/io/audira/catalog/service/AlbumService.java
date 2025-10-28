package io.audira.catalog.service;

import io.audira.catalog.model.Album;
import io.audira.catalog.model.Song;
import io.audira.catalog.repository.AlbumRepository;
import io.audira.catalog.repository.SongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AlbumService {

    private final AlbumRepository albumRepository;
    private final SongRepository songRepository;

    @Transactional
    public Album createAlbum(Album album) {
        // Log para debugging
        System.out.println("=== CREATE ALBUM DEBUG ===");
        System.out.println("Received Album:");
        System.out.println("  Title: " + album.getTitle());
        System.out.println("  coverImageUrl: " + album.getCoverImageUrl());
        System.out.println("  Artist ID: " + album.getArtistId());

        Album savedAlbum = albumRepository.save(album);

        System.out.println("Saved Album:");
        System.out.println("  ID: " + savedAlbum.getId());
        System.out.println("  Title: " + savedAlbum.getTitle());
        System.out.println("  coverImageUrl: " + savedAlbum.getCoverImageUrl());
        System.out.println("=========================");

        return savedAlbum;
    }

    public List<Album> getAllAlbums() {
        return albumRepository.findAll();
    }

    public Album getAlbumById(Long id) {
        Album album = albumRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Album not found with id: " + id));
        // Calculate and set price based on songs
        album.setPrice(calculateAlbumPrice(id));
        return album;
    }

    public BigDecimal calculateAlbumPrice(Long albumId) {
        List<Song> songs = songRepository.findByAlbumId(albumId);
        if (songs.isEmpty()) {
            return BigDecimal.ZERO;
        }

        BigDecimal totalSongsPrice = songs.stream()
                .map(Song::getPrice)
                .filter(price -> price != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Apply 15% discount by default
        BigDecimal discount = BigDecimal.valueOf(0.15);
        return totalSongsPrice.multiply(BigDecimal.ONE.subtract(discount));
    }

    public List<Album> getAlbumsByArtist(Long artistId) {
        return albumRepository.findByArtistId(artistId);
    }

    public List<Album> getAlbumsByGenre(Long genreId) {
        List<Album> albums = albumRepository.findByGenreId(genreId);
        // Calculate prices for each album
        albums.forEach(album -> album.setPrice(calculateAlbumPrice(album.getId())));
        return albums;
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

        // Log para debugging
        System.out.println("=== UPDATE ALBUM DEBUG ===");
        System.out.println("Album ID: " + id);
        System.out.println("Received coverImageUrl: " + albumDetails.getCoverImageUrl());
        System.out.println("Current coverImageUrl: " + album.getCoverImageUrl());

        // Update Product fields (inherited from Product)
        if (albumDetails.getTitle() != null && !albumDetails.getTitle().isEmpty()) {
            album.setTitle(albumDetails.getTitle());
        }

        if (albumDetails.getArtistId() != null) {
            album.setArtistId(albumDetails.getArtistId());
        }

        if (albumDetails.getCoverImageUrl() != null && !albumDetails.getCoverImageUrl().isEmpty()) {
            album.setCoverImageUrl(albumDetails.getCoverImageUrl());
            System.out.println("Setting new coverImageUrl: " + albumDetails.getCoverImageUrl());
        }

        if (albumDetails.getDescription() != null) {
            album.setDescription(albumDetails.getDescription());
        }

        // Update Album-specific fields
        if (albumDetails.getGenreIds() != null && !albumDetails.getGenreIds().isEmpty()) {
            album.setGenreIds(albumDetails.getGenreIds());
        }

        if (albumDetails.getReleaseDate() != null) {
            album.setReleaseDate(albumDetails.getReleaseDate());
        }

        // Allow manual price override
        if (albumDetails.getPrice() != null) {
            album.setPrice(albumDetails.getPrice());
        }

        Album savedAlbum = albumRepository.save(album);
        System.out.println("Saved coverImageUrl: " + savedAlbum.getCoverImageUrl());
        System.out.println("=======================");

        return savedAlbum;
    }

    @Transactional
    public void deleteAlbum(Long id) {
        if (!albumRepository.existsById(id)) {
            throw new IllegalArgumentException("Album not found with id: " + id);
        }
        albumRepository.deleteById(id);
    }
}
