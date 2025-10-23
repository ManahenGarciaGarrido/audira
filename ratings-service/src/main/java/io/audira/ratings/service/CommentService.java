package io.audira.ratings.service;

import io.audira.ratings.model.Comment;
import io.audira.ratings.model.EntityType;
import io.audira.ratings.repository.CommentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;

    @Transactional
    public Comment createComment(Long userId, EntityType entityType, Long entityId, String content, Long parentCommentId) {
        Comment comment = Comment.builder()
                .userId(userId)
                .entityType(entityType)
                .entityId(entityId)
                .content(content)
                .parentCommentId(parentCommentId)
                .build();
        return commentRepository.save(comment);
    }

    public List<Comment> getEntityComments(EntityType entityType, Long entityId) {
        return commentRepository.findByEntityTypeAndEntityIdAndParentCommentIdIsNull(entityType, entityId);
    }

    public List<Comment> getCommentReplies(Long commentId) {
        return commentRepository.findByParentCommentId(commentId);
    }

    public List<Comment> getUserComments(Long userId) {
        return commentRepository.findByUserId(userId);
    }

    public Comment getCommentById(Long commentId) {
        return commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));
    }

    @Transactional
    public Comment updateComment(Long commentId, String content) {
        Comment comment = getCommentById(commentId);
        comment.setContent(content);
        return commentRepository.save(comment);
    }

    @Transactional
    public void deleteComment(Long commentId) {
        commentRepository.deleteById(commentId);
    }
}
