package com.vithey.content.repository;

import com.vithey.content.entity.Post;
import com.vithey.content.entity.PostType;
import java.util.Collection;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PostRepository extends JpaRepository<Post, UUID> {

  Optional<Post> findByIdAndDeletedAtIsNull(UUID id);

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND post.authorId IN :authorIds
        AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR post.authorId = :viewerId)
      ORDER BY post.createdAt DESC
      """)
  Page<Post> findByAuthorIdInAndDeletedAtIsNullOrderByCreatedAtDesc(
      @Param("authorIds") Collection<UUID> authorIds,
      @Param("viewerId") UUID viewerId,
      Pageable pageable
  );

  @Query(
      value = """
          SELECT post
          FROM Post post
          WHERE post.deletedAt IS NULL
            AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR post.authorId = :viewerId)
          ORDER BY
            CASE WHEN post.authorId IN :prioritizedAuthorIds THEN 0 ELSE 1 END ASC,
            post.createdAt DESC
          """,
      countQuery = """
          SELECT count(post)
          FROM Post post
          WHERE post.deletedAt IS NULL
            AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR post.authorId = :viewerId)
          """
  )
  Page<Post> findAllPublishedWithPriority(
      @Param("prioritizedAuthorIds") Collection<UUID> prioritizedAuthorIds,
      @Param("viewerId") UUID viewerId,
      Pageable pageable
  );

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR post.authorId = :viewerId)
      ORDER BY post.createdAt DESC
      """)
  Page<Post> findAllPublished(
      @Param("viewerId") UUID viewerId,
      Pageable pageable
  );

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND post.authorId = :authorId
        AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR :isOwner = true)
      ORDER BY post.createdAt DESC
      """)
  Page<Post> findByAuthorIdAndDeletedAtIsNullOrderByCreatedAtDesc(
      @Param("authorId") UUID authorId,
      @Param("isOwner") boolean isOwner,
      Pageable pageable
  );

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND post.authorId = :authorId
        AND post.type = :type
        AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR :isOwner = true)
      ORDER BY post.createdAt DESC
      """)
  Page<Post> findByAuthorIdAndTypeAndDeletedAtIsNullOrderByCreatedAtDesc(
      @Param("authorId") UUID authorId,
      @Param("type") PostType type,
      @Param("isOwner") boolean isOwner,
      Pageable pageable
  );

  @Query(
      value = """
          SELECT post
          FROM Post post
          WHERE post.deletedAt IS NULL
            AND post.type = :type
            AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR post.authorId = :viewerId)
          ORDER BY
            CASE WHEN post.authorId IN :prioritizedAuthorIds THEN 0 ELSE 1 END ASC,
            post.createdAt DESC
          """,
      countQuery = """
          SELECT count(post)
          FROM Post post
          WHERE post.deletedAt IS NULL
            AND post.type = :type
            AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR post.authorId = :viewerId)
          """
  )
  Page<Post> findPublishedByTypeWithPriority(
      @Param("type") PostType type,
      @Param("prioritizedAuthorIds") Collection<UUID> prioritizedAuthorIds,
      @Param("viewerId") UUID viewerId,
      Pageable pageable
  );

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND post.type = :type
        AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP OR post.authorId = :viewerId)
      ORDER BY post.createdAt DESC
      """)
  Page<Post> findPublishedByType(
      @Param("type") PostType type,
      @Param("viewerId") UUID viewerId,
      Pageable pageable
  );

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP)
        AND (
          LOWER(post.content) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobTitle) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobDescription) LIKE LOWER(CONCAT('%', :search, '%'))
        )
      ORDER BY post.createdAt DESC
      """)
  Page<Post> searchByText(@Param("search") String search, Pageable pageable);

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND post.type = :type
        AND (post.scheduledAt IS NULL OR post.scheduledAt <= CURRENT_TIMESTAMP)
        AND (
          LOWER(post.content) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobTitle) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobDescription) LIKE LOWER(CONCAT('%', :search, '%'))
        )
      ORDER BY post.createdAt DESC
      """)
  Page<Post> searchByTextAndType(
      @Param("search") String search,
      @Param("type") PostType type,
      Pageable pageable
  );
}
