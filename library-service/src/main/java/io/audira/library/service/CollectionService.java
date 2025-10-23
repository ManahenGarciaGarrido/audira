package io.audira.library.service;

import io.audira.library.model.Collection;
import io.audira.library.repository.CollectionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CollectionService {

    private final CollectionRepository collectionRepository;

    @Transactional
    public Collection createCollection(Long userId, String name, String description) {
        Collection collection = Collection.builder()
                .userId(userId)
                .name(name)
                .description(description)
                .build();

        return collectionRepository.save(collection);
    }

    public List<Collection> getUserCollections(Long userId) {
        return collectionRepository.findByUserId(userId);
    }

    public Optional<Collection> getCollection(Long collectionId, Long userId) {
        return collectionRepository.findByIdAndUserId(collectionId, userId);
    }

    @Transactional
    public Collection updateCollection(Long collectionId, Long userId, String name, String description) {
        Optional<Collection> collectionOptional = collectionRepository.findByIdAndUserId(collectionId, userId);

        if (collectionOptional.isEmpty()) {
            throw new IllegalArgumentException("Collection not found");
        }

        Collection collection = collectionOptional.get();
        if (name != null) {
            collection.setName(name);
        }
        if (description != null) {
            collection.setDescription(description);
        }

        return collectionRepository.save(collection);
    }

    @Transactional
    public void deleteCollection(Long collectionId, Long userId) {
        collectionRepository.deleteByIdAndUserId(collectionId, userId);
    }

    @Transactional
    public Collection addItemToCollection(Long collectionId, Long userId, Long itemId) {
        Optional<Collection> collectionOptional = collectionRepository.findByIdAndUserId(collectionId, userId);

        if (collectionOptional.isEmpty()) {
            throw new IllegalArgumentException("Collection not found");
        }

        Collection collection = collectionOptional.get();
        if (!collection.getItemIds().contains(itemId)) {
            collection.getItemIds().add(itemId);
            return collectionRepository.save(collection);
        }

        return collection;
    }

    @Transactional
    public Collection removeItemFromCollection(Long collectionId, Long userId, Long itemId) {
        Optional<Collection> collectionOptional = collectionRepository.findByIdAndUserId(collectionId, userId);

        if (collectionOptional.isEmpty()) {
            throw new IllegalArgumentException("Collection not found");
        }

        Collection collection = collectionOptional.get();
        collection.getItemIds().remove(itemId);
        return collectionRepository.save(collection);
    }
}
