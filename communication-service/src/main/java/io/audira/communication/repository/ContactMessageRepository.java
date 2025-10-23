package io.audira.communication.repository;

import io.audira.communication.model.ContactMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ContactMessageRepository extends JpaRepository<ContactMessage, Long> {
    List<ContactMessage> findByUserId(Long userId);
    List<ContactMessage> findByStatus(ContactMessage.MessageStatus status);
    List<ContactMessage> findByMessageType(ContactMessage.MessageType messageType);
    List<ContactMessage> findByAssignedToUserId(Long assignedToUserId);
}
