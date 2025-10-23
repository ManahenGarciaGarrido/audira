package io.audira.catalog.controller;

import io.audira.catalog.model.Album;
import io.audira.catalog.model.Song;
import io.audira.catalog.service.DiscoveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/discovery")
@RequiredArgsConstructor
public class DiscoveryController {

    private final DiscoveryService discoveryService;

    @GetMapping("/search/songs")
    public ResponseEntity<List<Song>> searchSongs(@RequestParam String query) {
        return ResponseEntity.ok(discoveryService.searchSongs(query));
    }

    @GetMapping("/search/albums")
    public ResponseEntity<List<Album>> searchAlbums(@RequestParam String query) {
        return ResponseEntity.ok(discoveryService.searchAlbums(query));
    }

    @GetMapping("/trending/songs")
    public ResponseEntity<List<Song>> getTrendingSongs() {
        return ResponseEntity.ok(discoveryService.getTrendingSongs());
    }

    @GetMapping("/trending/albums")
    public ResponseEntity<List<Album>> getTrendingAlbums() {
        return ResponseEntity.ok(discoveryService.getTrendingAlbums());
    }

    @GetMapping("/recommendations")
    public ResponseEntity<List<Song>> getRecommendations(@RequestParam Long userId) {
        return ResponseEntity.ok(discoveryService.getRecommendations(userId));
    }
}
