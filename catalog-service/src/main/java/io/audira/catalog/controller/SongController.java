package io.audira.catalog.controller;

import io.audira.catalog.model.Song;
import io.audira.catalog.service.SongService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/songs")
@RequiredArgsConstructor
public class SongController {

    private final SongService songService;

    @PostMapping
    public ResponseEntity<Song> createSong(@RequestBody Song song) {
        return ResponseEntity.ok(songService.createSong(song));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Song> getSongById(@PathVariable Long id) {
        return ResponseEntity.ok(songService.getSongById(id));
    }

    @GetMapping
    public ResponseEntity<List<Song>> getAllSongs() {
        return ResponseEntity.ok(songService.getAllSongs());
    }

    @GetMapping("/artist/{artistId}")
    public ResponseEntity<List<Song>> getSongsByArtist(@PathVariable Long artistId) {
        return ResponseEntity.ok(songService.getSongsByArtist(artistId));
    }

    @GetMapping("/album/{albumId}")
    public ResponseEntity<List<Song>> getSongsByAlbum(@PathVariable Long albumId) {
        return ResponseEntity.ok(songService.getSongsByAlbum(albumId));
    }

    @GetMapping("/genre/{genreId}")
    public ResponseEntity<List<Song>> getSongsByGenre(@PathVariable Long genreId) {
        return ResponseEntity.ok(songService.getSongsByGenre(genreId));
    }

    @GetMapping("/search")
    public ResponseEntity<List<Song>> searchSongs(@RequestParam String query) {
        return ResponseEntity.ok(songService.searchSongs(query));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Song> updateSong(@PathVariable Long id, @RequestBody Song song) {
        return ResponseEntity.ok(songService.updateSong(id, song));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSong(@PathVariable Long id) {
        songService.deleteSong(id);
        return ResponseEntity.noContent().build();
    }
}
