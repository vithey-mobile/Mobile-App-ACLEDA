package com.vithey.ai.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "ai_cv_interactions")
@Getter
@Setter
@NoArgsConstructor
public class AiCvInteraction {

  @Id
  private UUID id;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(nullable = false, length = 64)
  private String section;

  @Column(name = "original_text", nullable = false, columnDefinition = "TEXT")
  private String originalText;

  @Column(name = "suggested_text", nullable = false, columnDefinition = "TEXT")
  private String suggestedText;

  @Column(name = "cv_id")
  private UUID cvId;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  @PrePersist
  void onCreate() {
    if (id == null) {
      id = UUID.randomUUID();
    }
    createdAt = Instant.now();
  }
}
