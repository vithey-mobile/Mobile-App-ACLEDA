package com.vithey.chat.repository;

import com.vithey.chat.entity.Message;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MessageRepository extends JpaRepository<Message, UUID> {

  Page<Message> findByConversationIdOrderByCreatedAtDesc(UUID conversationId, Pageable pageable);

  Optional<Message> findFirstByConversationIdOrderByCreatedAtDesc(UUID conversationId);
}
