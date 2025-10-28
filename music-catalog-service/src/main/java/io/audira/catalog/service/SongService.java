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
            if (updatedSong.getTitle() != null) {
                existingSong.setTitle(updatedSong.getTitle());
            }
            if (updatedSong.getDescription() != null) {
                existingSong.setDescription(updatedSong.getDescription());
            }
            if (updatedSong.getPrice() != null) {
                existingSong.setPrice(updatedSong.getPrice());
            }
            if (updatedSong.getCoverImageUrl() != null) {
                existingSong.setCoverImageUrl(updatedSong.getCoverImageUrl());
            }
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
            if (updatedSong.getGenreIds() != null) {
                existingSong.setGenreIds(updatedSong.getGenreIds());
            }
            return songRepository.save(existingSong);
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
