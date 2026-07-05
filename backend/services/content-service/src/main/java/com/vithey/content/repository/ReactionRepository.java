package com.vithey.content.repository;

import com.vithey.content.entity.Reaction;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReactionRepository extends JpaRepository<Reaction, UUID> {

  long countByPostId(UUID postId);

  Optional<Reaction> findByPostIdAndUserId(UUID postId, UUID userId);

  boolean existsByPostIdAndUserId(UUID postId, UUID userId);

  void deleteByPostIdAndUserId(UUID postId, UUID userId);
}
