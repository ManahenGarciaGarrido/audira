package io.audira.library.controller;

import io.audira.library.model.ItemType;
import io.audira.library.model.LibraryItem;
import io.audira.library.service.LibraryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/library")
@RequiredArgsConstructor
public class LibraryController {

    private final LibraryService libraryService;

    @PostMapping("/items")
    public ResponseEntity<LibraryItem> addToLibrary(
            @RequestParam Long userId,
            @RequestParam ItemType itemType,
            @RequestParam Long itemId) {
        return ResponseEntity.ok(libraryService.addToLibrary(userId, itemType, itemId));
    }

    @DeleteMapping("/items")
    public ResponseEntity<Void> removeFromLibrary(
            @RequestParam Long userId,
            @RequestParam ItemType itemType,
            @RequestParam Long itemId) {
        libraryService.removeFromLibrary(userId, itemType, itemId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<LibraryItem>> getUserLibrary(@PathVariable Long userId) {
        return ResponseEntity.ok(libraryService.getUserLibrary(userId));
    }

    @GetMapping("/user/{userId}/type/{itemType}")
    public ResponseEntity<List<LibraryItem>> getLibraryByType(
            @PathVariable Long userId,
            @PathVariable ItemType itemType) {
        return ResponseEntity.ok(libraryService.getLibraryByType(userId, itemType));
    }

    @GetMapping("/user/{userId}/favorites")
    public ResponseEntity<List<LibraryItem>> getFavorites(@PathVariable Long userId) {
        return ResponseEntity.ok(libraryService.getFavorites(userId));
    }

    @PutMapping("/items/{id}/favorite")
    public ResponseEntity<LibraryItem> toggleFavorite(@PathVariable Long id) {
        return ResponseEntity.ok(libraryService.toggleFavorite(id));
    }

    @DeleteMapping("/user/{userId}")
    public ResponseEntity<Void> clearLibrary(@PathVariable Long userId) {
        libraryService.clearLibrary(userId);
        return ResponseEntity.noContent().build();
    }
}
