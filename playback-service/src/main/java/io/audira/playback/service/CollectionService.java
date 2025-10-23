package io.audira.playback.service;

import io.audira.playback.model.Collection;
import io.audira.playback.repository.CollectionRepository;
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
    public Collection createCollection(Collection collection) {
        return collectionRepository.save(collection);
    }

    public List<Collection> getUserCollections(Long userId) {
        return collectionRepository.findByUserId(userId);
    }

    public Collection getCollectionById(Long collectionId) {
        return collectionRepository.findById(collectionId)
                .orElseThrow(() -> new IllegalArgumentException("Collection not found with id: " + collectionId));
    }

    public Optional<Collection> getCollection(Long collectionId, Long userId) {
        return collectionRepository.findByIdAndUserId(collectionId, userId);
    }

    @Transactional
    public Collection updateCollection(Long collectionId, Collection collectionDetails) {
        Collection collection = collectionRepository.findById(collectionId)
                .orElseThrow(() -> new IllegalArgumentException("Collection not found with id: " + collectionId));

        if (collectionDetails.getName() != null) {
            collection.setName(collectionDetails.getName());
        }
        if (collectionDetails.getDescription() != null) {
            collection.setDescription(collectionDetails.getDescription());
        }

        return collectionRepository.save(collection);
    }

    @Transactional
    public void deleteCollection(Long collectionId) {
        if (!collectionRepository.existsById(collectionId)) {
            throw new IllegalArgumentException("Collection not found with id: " + collectionId);
        }
        collectionRepository.deleteById(collectionId);
    }

    @Transactional
    public Collection addItemToCollection(Long collectionId, Long itemId) {
        Collection collection = collectionRepository.findById(collectionId)
                .orElseThrow(() -> new IllegalArgumentException("Collection not found with id: " + collectionId));

        if (!collection.getItemIds().contains(itemId)) {
            collection.getItemIds().add(itemId);
            return collectionRepository.save(collection);
        }

        return collection;
    }

    @Transactional
    public Collection removeItemFromCollection(Long collectionId, Long itemId) {
        Collection collection = collectionRepository.findById(collectionId)
                .orElseThrow(() -> new IllegalArgumentException("Collection not found with id: " + collectionId));

        collection.getItemIds().remove(itemId);
        return collectionRepository.save(collection);
    }
}
