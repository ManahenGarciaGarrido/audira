package io.audira.community.service;

import io.audira.community.model.ContactMessage;
import io.audira.community.repository.ContactMessageRepository;
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
    public ContactMessage createMessage(Long userId, String name, String email, String subject, String message, ContactMessage.MessageType messageType) {
        ContactMessage contactMessage = ContactMessage.builder()
                .userId(userId)
                .name(name)
                .email(email)
                .subject(subject)
                .message(message)
                .messageType(messageType != null ? messageType : ContactMessage.MessageType.GENERAL_INQUIRY)
                .status(ContactMessage.MessageStatus.PENDING)
                .build();
        return contactMessageRepository.save(contactMessage);
    }

    public List<ContactMessage> getUserMessages(Long userId) {
        return contactMessageRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<ContactMessage> getMessagesByStatus(ContactMessage.MessageStatus status) {
        return contactMessageRepository.findByStatus(status);
    }

    public ContactMessage getMessageById(Long id) {
        return contactMessageRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Message not found"));
    }

    @Transactional
    public ContactMessage updateStatus(Long id, ContactMessage.MessageStatus status) {
        ContactMessage message = getMessageById(id);
        message.setStatus(status);
        return contactMessageRepository.save(message);
    }

    @Transactional
    public ContactMessage respondToMessage(Long id, String response) {
        ContactMessage message = getMessageById(id);
        message.setResponse(response);
        message.setRespondedAt(LocalDateTime.now());
        message.setStatus(ContactMessage.MessageStatus.RESOLVED);
        return contactMessageRepository.save(message);
    }

    public List<ContactMessage> getAllMessages() {
        return contactMessageRepository.findAll();
    }
}
