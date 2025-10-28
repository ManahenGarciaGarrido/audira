    package io.audira.catalog.service;

    import io.audira.catalog.model.Song;
    import io.audira.catalog.repository.SongRepository;
    import lombok.RequiredArgsConstructor;
    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;
    import java.util.List;

    @Service
    @RequiredArgsConstructor
    public class SongService {

        private final SongRepository songRepository;

        @Transactional
        public Song createSong(Song song) {
            return songRepository.save(song);
        }

        public Song getSongById(Long id) {
            return songRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Song not found with id: " + id));
        }

        public List<Song> getAllSongs() {
            return songRepository.findAll();
        }

        public List<Song> getSongsByArtist(Long artistId) {
            return songRepository.findByArtistId(artistId);
        }

        public List<Song> getSongsByAlbum(Long albumId) {
            return songRepository.findByAlbumId(albumId);
        }

        public List<Song> getSongsByGenre(Long genreId) {
            return songRepository.findByGenreId(genreId);
        }

        @Transactional
        public Song updateSong(Long id, Song updatedSong) {
            Song existingSong = getSongById(id);

            // Log para debugging
            System.out.println("=== UPDATE SONG DEBUG ===");
            System.out.println("Song ID: " + id);
            System.out.println("Received coverImageUrl: " + updatedSong.getCoverImageUrl());
            System.out.println("Current coverImageUrl: " + existingSong.getCoverImageUrl());

            // Update Product fields (inherited from Product)
            if (updatedSong.getTitle() != null && !updatedSong.getTitle().isEmpty()) {
                existingSong.setTitle(updatedSong.getTitle());
            }
            if (updatedSong.getDescription() != null) {
                existingSong.setDescription(updatedSong.getDescription());
            }
            if (updatedSong.getPrice() != null) {
                existingSong.setPrice(updatedSong.getPrice());
            }
            if (updatedSong.getCoverImageUrl() != null && !updatedSong.getCoverImageUrl().isEmpty()) {
                existingSong.setCoverImageUrl(updatedSong.getCoverImageUrl());
                System.out.println("Setting new coverImageUrl: " + updatedSong.getCoverImageUrl());
            }
            if (updatedSong.getArtistId() != null) {
                existingSong.setArtistId(updatedSong.getArtistId());
            }

            // Update Song-specific fields
            if (updatedSong.getDuration() != null) {
                existingSong.setDuration(updatedSong.getDuration());
            }
            if (updatedSong.getAudioUrl() != null) {
                existingSong.setAudioUrl(updatedSong.getAudioUrl());
            }
            if (updatedSong.getLyrics() != null) {
                existingSong.setLyrics(updatedSong.getLyrics());
            }
            if (updatedSong.getAlbumId() != null) {
                existingSong.setAlbumId(updatedSong.getAlbumId());
            }
            if (updatedSong.getTrackNumber() != null) {
                existingSong.setTrackNumber(updatedSong.getTrackNumber());
            }
            if (updatedSong.getGenreIds() != null && !updatedSong.getGenreIds().isEmpty()) {
                existingSong.setGenreIds(updatedSong.getGenreIds());
            }

            Song savedSong = songRepository.save(existingSong);
            System.out.println("Saved coverImageUrl: " + savedSong.getCoverImageUrl());
            System.out.println("========================");

            return savedSong;
        }

        @Transactional
        public void deleteSong(Long id) {
            songRepository.deleteById(id);
        }

        public List<Song> searchSongs(String query) {
            return songRepository.searchByTitleOrArtist(query);
        }

        @Transactional
        public void incrementPlays(Long songId) {
            Song song = getSongById(songId);
            song.setPlays(song.getPlays() + 1);
            songRepository.save(song);
        }

        public List<Song> getTopSongsByPlays() {
            return songRepository.findTopByPlays();
        }

        public List<Song> getSongsByAlbumOrdered(Long albumId) {
            return songRepository.findByAlbumIdOrderByTrackNumberAsc(albumId);
        }
    }
