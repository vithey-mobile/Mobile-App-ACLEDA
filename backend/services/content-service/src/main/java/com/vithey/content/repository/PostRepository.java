package com.vithey.content.repository;

import com.vithey.content.entity.Post;
import com.vithey.content.entity.PostType;
import java.util.Collection;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepository extends JpaRepository<Post, UUID> {

  Optional<Post> findByIdAndDeletedAtIsNull(UUID id);

  Page<Post> findByAuthorIdInAndDeletedAtIsNullOrderByCreatedAtDesc(
      Collection<UUID> authorIds,
      Pageable pageable
  );

  Page<Post> findByAuthorIdAndDeletedAtIsNullOrderByCreatedAtDesc(UUID authorId, Pageable pageable);

  Page<Post> findByAuthorIdAndTypeAndDeletedAtIsNullOrderByCreatedAtDesc(
      UUID authorId,
      PostType type,
      Pageable pageable
  );
}
