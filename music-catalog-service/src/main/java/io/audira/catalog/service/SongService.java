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
        Song song = getSongById(id);
        if (updatedSong.getTitle() != null) song.setTitle(updatedSong.getTitle());
        if (updatedSong.getDuration() != null) song.setDuration(updatedSong.getDuration());
        if (updatedSong.getAudioUrl() != null) song.setAudioUrl(updatedSong.getAudioUrl());
        if (updatedSong.getPrice() != null) song.setPrice(updatedSong.getPrice());
        if (updatedSong.getLyrics() != null) song.setLyrics(updatedSong.getLyrics());
        return songRepository.save(song);
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
