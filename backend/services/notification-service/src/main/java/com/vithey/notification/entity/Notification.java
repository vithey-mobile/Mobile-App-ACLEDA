package com.vithey.notification.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "notifications")
@Getter
@Setter
public class Notification {

  @Id
  private UUID id;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 32)
  private NotificationType type;

  @Column(nullable = false, length = 180)
  private String title;

  @Column(nullable = false, columnDefinition = "TEXT")
  private String body;

  @Column(name = "reference_id")
  private UUID referenceId;

  @Column(name = "reference_type", length = 64)
  private String referenceType;

  @Column(name = "is_read", nullable = false)
  private boolean read;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;
}
