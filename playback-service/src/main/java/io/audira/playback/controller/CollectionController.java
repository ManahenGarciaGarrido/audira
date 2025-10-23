package io.audira.playback.controller;

import io.audira.playback.model.Collection;
import io.audira.playback.service.CollectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/library/collections")
@RequiredArgsConstructor
public class CollectionController {

    private final CollectionService collectionService;

    @PostMapping
    public ResponseEntity<Collection> createCollection(@RequestBody Collection collection) {
        return ResponseEntity.ok(collectionService.createCollection(collection));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Collection> getCollectionById(@PathVariable Long id) {
        return ResponseEntity.ok(collectionService.getCollectionById(id));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Collection>> getUserCollections(@PathVariable Long userId) {
        return ResponseEntity.ok(collectionService.getUserCollections(userId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Collection> updateCollection(
            @PathVariable Long id,
            @RequestBody Collection collection) {
        return ResponseEntity.ok(collectionService.updateCollection(id, collection));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCollection(@PathVariable Long id) {
        collectionService.deleteCollection(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/items")
    public ResponseEntity<Collection> addItemToCollection(
            @PathVariable Long id,
            @RequestParam Long itemId) {
        return ResponseEntity.ok(collectionService.addItemToCollection(id, itemId));
    }

    @DeleteMapping("/{id}/items/{itemId}")
    public ResponseEntity<Collection> removeItemFromCollection(
            @PathVariable Long id,
            @PathVariable Long itemId) {
        return ResponseEntity.ok(collectionService.removeItemFromCollection(id, itemId));
    }
}
