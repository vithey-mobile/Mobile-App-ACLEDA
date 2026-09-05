package com.vithey.chat.repository;

import com.vithey.chat.entity.ConversationParticipant;
import com.vithey.chat.entity.ConversationParticipantId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConversationParticipantRepository extends JpaRepository<ConversationParticipant, ConversationParticipantId> {

  List<ConversationParticipant> findByIdConversationId(UUID conversationId);

  Optional<ConversationParticipant> findByIdConversationIdAndIdUserId(UUID conversationId, UUID userId);
}
