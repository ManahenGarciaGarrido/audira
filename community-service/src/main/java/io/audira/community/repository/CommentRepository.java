package io.audira.community.repository;

import io.audira.community.model.Comment;
import io.audira.community.model.EntityType;
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
