package io.audira.ratings.repository;

import io.audira.ratings.model.Comment;
import io.audira.ratings.model.EntityType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findByEntityTypeAndEntityId(EntityType entityType, Long entityId);
    List<Comment> findByUserId(Long userId);
    List<Comment> findByParentCommentId(Long parentCommentId);
    List<Comment> findByEntityTypeAndEntityIdAndParentCommentIdIsNull(EntityType entityType, Long entityId);
}
