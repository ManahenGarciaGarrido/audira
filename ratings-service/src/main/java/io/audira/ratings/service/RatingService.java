package io.audira.ratings.service;

import io.audira.ratings.model.EntityType;
import io.audira.ratings.model.Rating;
import io.audira.ratings.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;

    @Transactional
    public Rating createOrUpdateRating(Long userId, EntityType entityType, Long entityId, Integer ratingValue) {
        if (ratingValue < 1 || ratingValue > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }

        Optional<Rating> existingRating = ratingRepository.findByUserIdAndEntityTypeAndEntityId(userId, entityType, entityId);

        if (existingRating.isPresent()) {
            Rating rating = existingRating.get();
            rating.setRating(ratingValue);
            return ratingRepository.save(rating);
        } else {
            Rating newRating = Rating.builder()
                    .userId(userId)
                    .entityType(entityType)
                    .entityId(entityId)
                    .rating(ratingValue)
                    .build();
            return ratingRepository.save(newRating);
        }
    }

    public Optional<Rating> getUserRating(Long userId, EntityType entityType, Long entityId) {
        return ratingRepository.findByUserIdAndEntityTypeAndEntityId(userId, entityType, entityId);
    }

    public List<Rating> getEntityRatings(EntityType entityType, Long entityId) {
        return ratingRepository.findByEntityTypeAndEntityId(entityType, entityId);
    }

    public Double getAverageRating(EntityType entityType, Long entityId) {
        return ratingRepository.getAverageRating(entityType, entityId);
    }

    public Long getRatingCount(EntityType entityType, Long entityId) {
        return ratingRepository.countRatings(entityType, entityId);
    }

    @Transactional
    public void deleteRating(Long ratingId) {
        ratingRepository.deleteById(ratingId);
    }

    public List<Rating> getUserRatings(Long userId) {
        return ratingRepository.findByUserId(userId);
    }
}
