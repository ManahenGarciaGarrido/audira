package io.audira.communication.service;

import io.audira.communication.model.ContactMessage;
import io.audira.communication.repository.ContactMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ContactMessageService {

    private final ContactMessageRepository contactMessageRepository;

    public List<ContactMessage> getAllMessages() {
        return contactMessageRepository.findAll();
    }

    public ContactMessage getMessageById(Long id) {
        return contactMessageRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Contact message not found with id: " + id));
    }

    public List<ContactMessage> getMessagesByUserId(Long userId) {
        return contactMessageRepository.findByUserId(userId);
    }

    public List<ContactMessage> getMessagesByStatus(ContactMessage.MessageStatus status) {
        return contactMessageRepository.findByStatus(status);
    }

    public List<ContactMessage> getMessagesByType(ContactMessage.MessageType messageType) {
        return contactMessageRepository.findByMessageType(messageType);
    }

    public List<ContactMessage> getAssignedMessages(Long assignedToUserId) {
        return contactMessageRepository.findByAssignedToUserId(assignedToUserId);
    }

    @Transactional
    public ContactMessage createMessage(ContactMessage message) {
        return contactMessageRepository.save(message);
    }

    @Transactional
    public ContactMessage updateMessageStatus(Long id, ContactMessage.MessageStatus status) {
        ContactMessage message = getMessageById(id);
        message.setStatus(status);
        return contactMessageRepository.save(message);
    }

    @Transactional
    public ContactMessage assignMessage(Long id, Long assignedToUserId) {
        ContactMessage message = getMessageById(id);
        message.setAssignedToUserId(assignedToUserId);
        message.setStatus(ContactMessage.MessageStatus.IN_PROGRESS);
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

    @Transactional
    public void deleteMessage(Long id) {
        contactMessageRepository.deleteById(id);
    }
}
