package io.audira.library.repository;

import io.audira.library.model.ItemType;
import io.audira.library.model.LibraryItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface LibraryItemRepository extends JpaRepository<LibraryItem, Long> {
    List<LibraryItem> findByUserId(Long userId);
    List<LibraryItem> findByUserIdAndItemType(Long userId, ItemType itemType);
    List<LibraryItem> findByUserIdAndIsFavorite(Long userId, Boolean isFavorite);
    Optional<LibraryItem> findByUserIdAndItemTypeAndItemId(Long userId, ItemType itemType, Long itemId);
    boolean existsByUserIdAndItemTypeAndItemId(Long userId, ItemType itemType, Long itemId);
    void deleteByUserIdAndItemTypeAndItemId(Long userId, ItemType itemType, Long itemId);

    @Modifying
    void deleteByUserId(Long userId);
}