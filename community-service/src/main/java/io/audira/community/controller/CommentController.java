package io.audira.community.controller;

import io.audira.community.model.Comment;
import io.audira.community.model.EntityType;
import io.audira.community.service.CommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;

    @PostMapping
    public ResponseEntity<Comment> createComment(
            @RequestParam Long userId,
            @RequestParam EntityType entityType,
            @RequestParam Long entityId,
            @RequestParam String content,
            @RequestParam(required = false) Long parentCommentId) {
        return ResponseEntity.ok(commentService.createComment(userId, entityType, entityId, content, parentCommentId));
    }

    @GetMapping("/entity/{entityType}/{entityId}")
    public ResponseEntity<List<Comment>> getEntityComments(
            @PathVariable EntityType entityType,
            @PathVariable Long entityId) {
        return ResponseEntity.ok(commentService.getEntityComments(entityType, entityId));
    }

    @GetMapping("/{commentId}/replies")
    public ResponseEntity<List<Comment>> getCommentReplies(@PathVariable Long commentId) {
        return ResponseEntity.ok(commentService.getCommentReplies(commentId));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Comment>> getUserComments(@PathVariable Long userId) {
        return ResponseEntity.ok(commentService.getUserComments(userId));
    }

    @GetMapping("/{commentId}")
    public ResponseEntity<Comment> getComment(@PathVariable Long commentId) {
        return ResponseEntity.ok(commentService.getCommentById(commentId));
    }

    @PutMapping("/{commentId}")
    public ResponseEntity<Comment> updateComment(
            @PathVariable Long commentId,
            @RequestParam String content) {
        return ResponseEntity.ok(commentService.updateComment(commentId, content));
    }

    @DeleteMapping("/{commentId}")
    public ResponseEntity<Void> deleteComment(@PathVariable Long commentId) {
        commentService.deleteComment(commentId);
        return ResponseEntity.noContent().build();
    }
}
