package io.audira.communication.controller;

import io.audira.communication.model.ContactMessage;
import io.audira.communication.service.ContactMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/contact")
@RequiredArgsConstructor
public class ContactMessageController {

    private final ContactMessageService contactMessageService;

    @GetMapping
    public ResponseEntity<List<ContactMessage>> getAllMessages() {
        return ResponseEntity.ok(contactMessageService.getAllMessages());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContactMessage> getMessageById(@PathVariable Long id) {
        return ResponseEntity.ok(contactMessageService.getMessageById(id));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ContactMessage>> getMessagesByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(contactMessageService.getMessagesByUserId(userId));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<ContactMessage>> getMessagesByStatus(@PathVariable ContactMessage.MessageStatus status) {
        return ResponseEntity.ok(contactMessageService.getMessagesByStatus(status));
    }

    @GetMapping("/type/{messageType}")
    public ResponseEntity<List<ContactMessage>> getMessagesByType(@PathVariable ContactMessage.MessageType messageType) {
        return ResponseEntity.ok(contactMessageService.getMessagesByType(messageType));
    }

    @GetMapping("/assigned/{assignedToUserId}")
    public ResponseEntity<List<ContactMessage>> getAssignedMessages(@PathVariable Long assignedToUserId) {
        return ResponseEntity.ok(contactMessageService.getAssignedMessages(assignedToUserId));
    }

    @PostMapping
    public ResponseEntity<ContactMessage> createMessage(@RequestBody ContactMessage message) {
        return ResponseEntity.status(HttpStatus.CREATED).body(contactMessageService.createMessage(message));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ContactMessage> updateMessageStatus(
            @PathVariable Long id,
            @RequestParam ContactMessage.MessageStatus status) {
        return ResponseEntity.ok(contactMessageService.updateMessageStatus(id, status));
    }

    @PutMapping("/{id}/assign")
    public ResponseEntity<ContactMessage> assignMessage(
            @PathVariable Long id,
            @RequestParam Long assignedToUserId) {
        return ResponseEntity.ok(contactMessageService.assignMessage(id, assignedToUserId));
    }

    @PutMapping("/{id}/respond")
    public ResponseEntity<ContactMessage> respondToMessage(
            @PathVariable Long id,
            @RequestBody String response) {
        return ResponseEntity.ok(contactMessageService.respondToMessage(id, response));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMessage(@PathVariable Long id) {
        contactMessageService.deleteMessage(id);
        return ResponseEntity.noContent().build();
    }
}
