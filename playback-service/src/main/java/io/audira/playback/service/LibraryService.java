package io.audira.playback.service;

import io.audira.playback.model.ItemType;
import io.audira.playback.model.LibraryItem;
import io.audira.playback.repository.LibraryItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LibraryService {

    private final LibraryItemRepository libraryItemRepository;

    @Transactional
    public LibraryItem addToLibrary(Long userId, ItemType itemType, Long itemId) {
        // Check if item already exists in library
        if (libraryItemRepository.existsByUserIdAndItemTypeAndItemId(userId, itemType, itemId)) {
            throw new IllegalArgumentException("Item already exists in library");
        }

        LibraryItem libraryItem = LibraryItem.builder()
                .userId(userId)
                .itemType(itemType)
                .itemId(itemId)
                .isFavorite(false)
                .build();

        return libraryItemRepository.save(libraryItem);
    }

    @Transactional
    public void removeFromLibrary(Long userId, ItemType itemType, Long itemId) {
        libraryItemRepository.deleteByUserIdAndItemTypeAndItemId(userId, itemType, itemId);
    }

    public List<LibraryItem> getUserLibrary(Long userId) {
        return libraryItemRepository.findByUserId(userId);
    }

    // FIX: Renamed from 'getUserLibraryByType' to match controller
    public List<LibraryItem> getLibraryByType(Long userId, ItemType itemType) {
        return libraryItemRepository.findByUserIdAndItemType(userId, itemType);
    }

    // FIX: Renamed from 'getUserFavorites' to match controller
    public List<LibraryItem> getFavorites(Long userId) {
        return libraryItemRepository.findByUserIdAndIsFavorite(userId, true);
    }

    @Transactional
    public LibraryItem toggleFavorite(Long userId, ItemType itemType, Long itemId) {
        Optional<LibraryItem> itemOptional = libraryItemRepository
                .findByUserIdAndItemTypeAndItemId(userId, itemType, itemId);

        if (itemOptional.isEmpty()) {
            throw new IllegalArgumentException("Item not found in library");
        }

        LibraryItem item = itemOptional.get();
        item.setIsFavorite(!item.getIsFavorite());
        return libraryItemRepository.save(item);
    }

    public boolean isInLibrary(Long userId, ItemType itemType, Long itemId) {
        return libraryItemRepository.existsByUserIdAndItemTypeAndItemId(userId, itemType, itemId);
    }

    public Optional<LibraryItem> getLibraryItem(Long userId, ItemType itemType, Long itemId) {
        return libraryItemRepository.findByUserIdAndItemTypeAndItemId(userId, itemType, itemId);
    }

    // FIX: Added missing 'clearLibrary' method
    @Transactional
    public void clearLibrary(Long userId) {
        libraryItemRepository.deleteByUserId(userId);
    }
}