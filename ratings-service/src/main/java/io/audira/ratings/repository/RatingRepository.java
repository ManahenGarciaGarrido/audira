package io.audira.ratings.repository;

import io.audira.ratings.model.EntityType;
import io.audira.ratings.model.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface RatingRepository extends JpaRepository<Rating, Long> {
    Optional<Rating> findByUserIdAndEntityTypeAndEntityId(Long userId, EntityType entityType, Long entityId);
    List<Rating> findByEntityTypeAndEntityId(EntityType entityType, Long entityId);
    List<Rating> findByUserId(Long userId);

    @Query("SELECT AVG(r.rating) FROM Rating r WHERE r.entityType = :entityType AND r.entityId = :entityId")
    Double getAverageRating(EntityType entityType, Long entityId);

    @Query("SELECT COUNT(r) FROM Rating r WHERE r.entityType = :entityType AND r.entityId = :entityId")
    Long countRatings(EntityType entityType, Long entityId);
}
