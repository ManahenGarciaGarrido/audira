package io.audira.catalog.controller;

import io.audira.catalog.model.Collaboration;
import io.audira.catalog.service.CollaborationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/collaborations")
@RequiredArgsConstructor
public class CollaborationController {

    private final CollaborationService collaborationService;

    @PostMapping
    public ResponseEntity<Collaboration> createCollaboration(@RequestBody Collaboration collaboration) {
        return ResponseEntity.ok(collaborationService.createCollaboration(collaboration));
    }

    @GetMapping("/song/{songId}")
    public ResponseEntity<List<Collaboration>> getCollaborationsBySong(@PathVariable Long songId) {
        return ResponseEntity.ok(collaborationService.getCollaborationsBySong(songId));
    }

    @GetMapping("/artist/{artistId}")
    public ResponseEntity<List<Collaboration>> getCollaborationsByArtist(@PathVariable Long artistId) {
        return ResponseEntity.ok(collaborationService.getCollaborationsByArtist(artistId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCollaboration(@PathVariable Long id) {
        collaborationService.deleteCollaboration(id);
        return ResponseEntity.noContent().build();
    }
}
