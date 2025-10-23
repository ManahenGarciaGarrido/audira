package io.audira.catalog.controller;

import io.audira.catalog.model.Collaborator;
import io.audira.catalog.service.CollaboratorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/")
@RequiredArgsConstructor
public class CollaboratorController {

    private final CollaboratorService collaboratorService;

    @PostMapping("/collaborations")
    public ResponseEntity<Collaborator> addCollaborator(@RequestBody Collaborator collaborator) {
        Collaborator created = collaboratorService.addCollaborator(collaborator);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/collaborations/song/{songId}")
    public ResponseEntity<List<Collaborator>> getCollaboratorsBySong(@PathVariable Long songId) {
        return ResponseEntity.ok(collaboratorService.getCollaboratorsBySong(songId));
    }

    @GetMapping("/collaborations/artist/{artistId}")
    public ResponseEntity<List<Collaborator>> getCollaborationsByArtist(@PathVariable Long artistId) {
        return ResponseEntity.ok(collaboratorService.getCollaborationsByArtist(artistId));
    }

    @DeleteMapping("/collaborations/{id}")
    public ResponseEntity<Void> removeCollaborator(@PathVariable Long id) {
        collaboratorService.removeCollaborator(id);
        return ResponseEntity.noContent().build();
    }
}
