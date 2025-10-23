package io.audira.communication.service;

import io.audira.communication.model.ContactMessage;
import io.audira.communication.model.MessageStatus;
import io.audira.communication.repository.ContactMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ContactService {

    private final ContactMessageRepository contactMessageRepository;

    @Transactional
    public ContactMessage createMessage(Long userId, String email, String subject, String message) {
        ContactMessage contactMessage = ContactMessage.builder()
                .userId(userId)
                .email(email)
                .subject(subject)
                .message(message)
                .status(MessageStatus.PENDING)
                .build();
        return contactMessageRepository.save(contactMessage);
    }

    public List<ContactMessage> getUserMessages(Long userId) {
        return contactMessageRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<ContactMessage> getMessagesByStatus(MessageStatus status) {
        return contactMessageRepository.findByStatus(status);
    }

    public ContactMessage getMessageById(Long id) {
        return contactMessageRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Message not found"));
    }

    @Transactional
    public ContactMessage updateStatus(Long id, MessageStatus status) {
        ContactMessage message = getMessageById(id);
        message.setStatus(status);
        return contactMessageRepository.save(message);
    }

    @Transactional
    public ContactMessage respondToMessage(Long id, String response) {
        ContactMessage message = getMessageById(id);
        message.setResponse(response);
        message.setRespondedAt(LocalDateTime.now());
        message.setStatus(MessageStatus.RESOLVED);
        return contactMessageRepository.save(message);
    }

    public List<ContactMessage> getAllMessages() {
        return contactMessageRepository.findAll();
    }
}
