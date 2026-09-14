package com.vithey.ai.repository;

import com.vithey.ai.entity.AiChatSession;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AiChatSessionRepository extends JpaRepository<AiChatSession, UUID> {

  Page<AiChatSession> findByUserIdOrderByUpdatedAtDesc(UUID userId, Pageable pageable);

  Optional<AiChatSession> findByIdAndUserId(UUID id, UUID userId);
}
