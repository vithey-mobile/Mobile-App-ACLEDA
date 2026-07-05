package com.vithey.profile.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "profiles")
@Getter
@Setter
public class Profile {

  @Id
  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(name = "full_name", nullable = false, length = 160)
  private String fullName;

  @Column(name = "bio")
  private String bio;

  @Column(name = "avatar_file_id")
  private UUID avatarFileId;

  @Column(name = "avatar_url")
  private String avatarUrl;

  @Column(name = "telegram_link")
  private String telegramLink;

  @Column(name = "facebook_link")
  private String facebookLink;

  @Column(name = "university", length = 160)
  private String university;

  @Column(name = "major", length = 160)
  private String major;

  @Column(name = "graduation_year")
  private Integer graduationYear;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @PrePersist
  void onCreate() {
    OffsetDateTime now = OffsetDateTime.now();
    createdAt = now;
    updatedAt = now;
  }

  @PreUpdate
  void onUpdate() {
    updatedAt = OffsetDateTime.now();
  }
}
