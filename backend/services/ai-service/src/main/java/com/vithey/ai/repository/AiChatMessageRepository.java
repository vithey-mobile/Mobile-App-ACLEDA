package com.vithey.ai.repository;

import com.vithey.ai.entity.AiChatMessage;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AiChatMessageRepository extends JpaRepository<AiChatMessage, UUID> {

  Page<AiChatMessage> findBySessionIdOrderByCreatedAtAsc(UUID sessionId, Pageable pageable);
}
