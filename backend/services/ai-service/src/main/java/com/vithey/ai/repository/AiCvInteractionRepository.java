package com.vithey.ai.repository;

import com.vithey.ai.entity.AiCvInteraction;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AiCvInteractionRepository extends JpaRepository<AiCvInteraction, UUID> {
}
