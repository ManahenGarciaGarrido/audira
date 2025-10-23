package io.audira.playback.service;

import io.audira.playback.dto.*;
import io.audira.playback.model.Playlist;
import io.audira.playback.model.PlaylistSong;
import io.audira.playback.repository.PlaylistRepository;
import io.audira.playback.repository.PlaylistSongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlaylistService {

    private final PlaylistRepository playlistRepository;
    private final PlaylistSongRepository playlistSongRepository;

    @Transactional
    public PlaylistDTO createPlaylist(CreatePlaylistRequest request) {
        Playlist playlist = Playlist.builder()
                .userId(request.getUserId())
                .name(request.getName())
                .description(request.getDescription())
                .coverImageUrl(request.getCoverImageUrl())
                .isPublic(request.getIsPublic())
                .build();

        playlist = playlistRepository.save(playlist);
        return mapToDTO(playlist);
    }

    public PlaylistDTO getPlaylistById(Long id) {
        Playlist playlist = playlistRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Playlist not found with id: " + id));
        return mapToDTO(playlist);
    }

    public List<PlaylistDTO> getAllPlaylists() {
        return playlistRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<PlaylistDTO> getUserPlaylists(Long userId) {
        return playlistRepository.findByUserId(userId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<PlaylistDTO> getPublicPlaylists() {
        return playlistRepository.findByIsPublicTrue().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<PlaylistDTO> getUserPublicPlaylists(Long userId) {
        return playlistRepository.findByUserIdAndIsPublicTrue(userId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public PlaylistDTO updatePlaylist(Long id, UpdatePlaylistRequest request) {
        Playlist playlist = playlistRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Playlist not found with id: " + id));

        if (request.getName() != null) {
            playlist.setName(request.getName());
        }
        if (request.getDescription() != null) {
            playlist.setDescription(request.getDescription());
        }
        if (request.getCoverImageUrl() != null) {
            playlist.setCoverImageUrl(request.getCoverImageUrl());
        }
        if (request.getIsPublic() != null) {
            playlist.setIsPublic(request.getIsPublic());
        }

        playlist = playlistRepository.save(playlist);
        return mapToDTO(playlist);
    }

    @Transactional
    public void deletePlaylist(Long id) {
        Playlist playlist = playlistRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Playlist not found with id: " + id));

        // Delete all playlist songs first
        playlistSongRepository.deleteByPlaylistId(id);
        playlistRepository.delete(playlist);
    }

    @Transactional
    public PlaylistDTO addSongToPlaylist(Long playlistId, AddSongRequest request) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found with id: " + playlistId));

        // Check if song already exists in playlist
        if (playlist.getSongIds().contains(request.getSongId())) {
            throw new RuntimeException("Song already exists in playlist");
        }

        // Determine position
        int position = request.getPosition() != null ? request.getPosition() : playlist.getSongIds().size();

        // Add to specified position or end
        if (position >= playlist.getSongIds().size()) {
            playlist.getSongIds().add(request.getSongId());
        } else {
            playlist.getSongIds().add(position, request.getSongId());
        }

        // Create PlaylistSong entry
        PlaylistSong playlistSong = PlaylistSong.builder()
                .playlistId(playlistId)
                .songId(request.getSongId())
                .position(position)
                .build();
        playlistSongRepository.save(playlistSong);

        playlist = playlistRepository.save(playlist);
        return mapToDTO(playlist);
    }

    @Transactional
    public PlaylistDTO removeSongFromPlaylist(Long playlistId, Long songId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found with id: " + playlistId));

        if (!playlist.getSongIds().contains(songId)) {
            throw new RuntimeException("Song not found in playlist");
        }

        playlist.getSongIds().remove(songId);
        playlistSongRepository.deleteByPlaylistIdAndSongId(playlistId, songId);

        playlist = playlistRepository.save(playlist);
        return mapToDTO(playlist);
    }

    @Transactional
    public PlaylistDTO reorderSongs(Long playlistId, ReorderSongsRequest request) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found with id: " + playlistId));

        // Validate that all songs in the request exist in the playlist
        if (!playlist.getSongIds().containsAll(request.getSongIds()) ||
            playlist.getSongIds().size() != request.getSongIds().size()) {
            throw new RuntimeException("Invalid song IDs for reordering");
        }

        // Update the order
        playlist.setSongIds(request.getSongIds());

        // Update positions in PlaylistSong entries
        List<PlaylistSong> playlistSongs = playlistSongRepository.findByPlaylistIdOrderByPositionAsc(playlistId);
        for (int i = 0; i < request.getSongIds().size(); i++) {
            Long songId = request.getSongIds().get(i);
            PlaylistSong playlistSong = playlistSongs.stream()
                    .filter(ps -> ps.getSongId().equals(songId))
                    .findFirst()
                    .orElse(null);
            if (playlistSong != null) {
                playlistSong.setPosition(i);
                playlistSongRepository.save(playlistSong);
            }
        }

        playlist = playlistRepository.save(playlist);
        return mapToDTO(playlist);
    }

    public List<PlaylistSongDTO> getPlaylistSongs(Long playlistId) {
        return playlistSongRepository.findByPlaylistIdOrderByPositionAsc(playlistId).stream()
                .map(this::mapToSongDTO)
                .collect(Collectors.toList());
    }

    private PlaylistDTO mapToDTO(Playlist playlist) {
        return PlaylistDTO.builder()
                .id(playlist.getId())
                .userId(playlist.getUserId())
                .name(playlist.getName())
                .description(playlist.getDescription())
                .coverImageUrl(playlist.getCoverImageUrl())
                .isPublic(playlist.getIsPublic())
                .songIds(playlist.getSongIds())
                .createdAt(playlist.getCreatedAt())
                .updatedAt(playlist.getUpdatedAt())
                .build();
    }

    private PlaylistSongDTO mapToSongDTO(PlaylistSong playlistSong) {
        return PlaylistSongDTO.builder()
                .id(playlistSong.getId())
                .playlistId(playlistSong.getPlaylistId())
                .songId(playlistSong.getSongId())
                .position(playlistSong.getPosition())
                .addedAt(playlistSong.getAddedAt())
                .build();
    }
}
