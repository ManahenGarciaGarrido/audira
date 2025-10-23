package io.audira.playlist.controller;

import io.audira.playlist.dto.*;
import io.audira.playlist.service.PlaylistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/playlists")
@RequiredArgsConstructor
public class PlaylistController {

    private final PlaylistService playlistService;

    @PostMapping
    public ResponseEntity<PlaylistDTO> createPlaylist(@RequestBody CreatePlaylistRequest request) {
        return ResponseEntity.ok(playlistService.createPlaylist(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlaylistDTO> getPlaylistById(@PathVariable Long id) {
        return ResponseEntity.ok(playlistService.getPlaylistById(id));
    }

    @GetMapping
    public ResponseEntity<List<PlaylistDTO>> getAllPlaylists() {
        return ResponseEntity.ok(playlistService.getAllPlaylists());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<PlaylistDTO>> getUserPlaylists(@PathVariable Long userId) {
        return ResponseEntity.ok(playlistService.getUserPlaylists(userId));
    }

    @GetMapping("/public")
    public ResponseEntity<List<PlaylistDTO>> getPublicPlaylists() {
        return ResponseEntity.ok(playlistService.getPublicPlaylists());
    }

    @GetMapping("/public/user/{userId}")
    public ResponseEntity<List<PlaylistDTO>> getUserPublicPlaylists(@PathVariable Long userId) {
        return ResponseEntity.ok(playlistService.getUserPublicPlaylists(userId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<PlaylistDTO> updatePlaylist(
            @PathVariable Long id,
            @RequestBody UpdatePlaylistRequest request) {
        return ResponseEntity.ok(playlistService.updatePlaylist(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePlaylist(@PathVariable Long id) {
        playlistService.deletePlaylist(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/songs")
    public ResponseEntity<PlaylistDTO> addSongToPlaylist(
            @PathVariable Long id,
            @RequestBody AddSongRequest request) {
        return ResponseEntity.ok(playlistService.addSongToPlaylist(id, request));
    }

    @DeleteMapping("/{id}/songs/{songId}")
    public ResponseEntity<PlaylistDTO> removeSongFromPlaylist(
            @PathVariable Long id,
            @PathVariable Long songId) {
        return ResponseEntity.ok(playlistService.removeSongFromPlaylist(id, songId));
    }

    @PutMapping("/{id}/songs/reorder")
    public ResponseEntity<PlaylistDTO> reorderSongs(
            @PathVariable Long id,
            @RequestBody ReorderSongsRequest request) {
        return ResponseEntity.ok(playlistService.reorderSongs(id, request));
    }

    @GetMapping("/{id}/songs")
    public ResponseEntity<List<PlaylistSongDTO>> getPlaylistSongs(@PathVariable Long id) {
        return ResponseEntity.ok(playlistService.getPlaylistSongs(id));
    }
}
