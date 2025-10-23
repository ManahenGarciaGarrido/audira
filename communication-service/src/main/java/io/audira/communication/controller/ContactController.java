package io.audira.communication.controller;

import io.audira.communication.model.ContactMessage;
import io.audira.communication.service.ContactService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/contact")
@RequiredArgsConstructor
public class ContactController {

    private final ContactService contactService;

    @PostMapping
    public ResponseEntity<ContactMessage> createMessage(
            @RequestParam Long userId,
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String subject,
            @RequestParam String message,
            @RequestParam(required = false) ContactMessage.MessageType messageType) {
        return ResponseEntity.ok(contactService.createMessage(userId, name, email, subject, message, messageType));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ContactMessage>> getUserMessages(@PathVariable Long userId) {
        return ResponseEntity.ok(contactService.getUserMessages(userId));
    }

    @GetMapping
    public ResponseEntity<List<ContactMessage>> getAllMessages() {
        return ResponseEntity.ok(contactService.getAllMessages());
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<ContactMessage>> getMessagesByStatus(@PathVariable ContactMessage.MessageStatus status) {
        return ResponseEntity.ok(contactService.getMessagesByStatus(status));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContactMessage> getMessageById(@PathVariable Long id) {
        return ResponseEntity.ok(contactService.getMessageById(id));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ContactMessage> updateStatus(
            @PathVariable Long id,
            @RequestParam ContactMessage.MessageStatus status) {
        return ResponseEntity.ok(contactService.updateStatus(id, status));
    }

    @PostMapping("/{id}/respond")
    public ResponseEntity<ContactMessage> respondToMessage(
            @PathVariable Long id,
            @RequestParam String response) {
        return ResponseEntity.ok(contactService.respondToMessage(id, response));
    }
}
