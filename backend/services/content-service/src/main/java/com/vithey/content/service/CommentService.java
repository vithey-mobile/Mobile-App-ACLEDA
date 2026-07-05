package com.vithey.content.service;

import com.vithey.content.dto.request.CreateCommentRequest;
import com.vithey.content.dto.response.CommentResponse;
import com.vithey.content.entity.Comment;
import com.vithey.content.entity.Mention;
import com.vithey.content.event.payload.CommentAddedEvent;
import com.vithey.content.event.payload.MentionCreatedEvent;
import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.mapper.CommentMapper;
import com.vithey.content.repository.CommentRepository;
import com.vithey.content.repository.MentionRepository;
import com.vithey.content.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CommentService {

  private static final int DEFAULT_LIMIT = 20;
  private static final int MAX_LIMIT = 50;

  private final CommentRepository commentRepository;
  private final MentionRepository mentionRepository;
  private final PostService postService;
  private final CommentMapper commentMapper;
  private final PostEnrichmentService postEnrichmentService;
  private final ContentEventPublisher contentEventPublisher;

  public CommentService(
      CommentRepository commentRepository,
      MentionRepository mentionRepository,
      PostService postService,
      CommentMapper commentMapper,
      PostEnrichmentService postEnrichmentService,
      ContentEventPublisher contentEventPublisher
  ) {
    this.commentRepository = commentRepository;
    this.mentionRepository = mentionRepository;
    this.postService = postService;
    this.commentMapper = commentMapper;
    this.postEnrichmentService = postEnrichmentService;
    this.contentEventPublisher = contentEventPublisher;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<CommentResponse>> getComments(UUID postId, int page, int limit) {
    postService.requireActivePost(postId);

    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Comment> comments = commentRepository.findByPostIdOrderByCreatedAtDesc(postId, pageable);
    List<CommentResponse> content = comments.getContent().stream()
        .map(this::toResponse)
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, comments.getTotalElements(), comments.getTotalPages())
    );
  }

  @Transactional
  public CommentResponse addComment(UUID postId, UUID authorId, CreateCommentRequest request) {
    postService.requireActivePost(postId);

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Comment comment = new Comment();
    comment.setId(UUID.randomUUID());
    comment.setPostId(postId);
    comment.setAuthorId(authorId);
    comment.setText(request.text());
    comment.setCreatedAt(now);
    Comment saved = commentRepository.save(comment);

    contentEventPublisher.publishCommentAdded(new CommentAddedEvent(
        saved.getId(),
        saved.getPostId(),
        saved.getAuthorId(),
        saved.getText(),
        saved.getCreatedAt()
    ));

    if (request.mentionUserIds() != null) {
      for (UUID mentionedUserId : request.mentionUserIds()) {
        Mention mention = new Mention();
        mention.setId(UUID.randomUUID());
        mention.setCommentId(saved.getId());
        mention.setMentionedUserId(mentionedUserId);
        mentionRepository.save(mention);
        contentEventPublisher.publishMentionCreated(new MentionCreatedEvent(
            mention.getId(),
            mention.getCommentId(),
            mention.getMentionedUserId(),
            postId
        ));
      }
    }

    return toResponse(saved);
  }

  private CommentResponse toResponse(Comment comment) {
    CommentResponse base = commentMapper.toBaseResponse(comment);
    return new CommentResponse(
        base.commentId(),
        base.postId(),
        postEnrichmentService.resolveAuthor(comment.getAuthorId()),
        base.text(),
        base.createdAt()
    );
  }
}
