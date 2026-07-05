package com.vithey.content.service;

import com.vithey.content.client.FileServiceClient;
import com.vithey.content.client.UserProfileClient;
import com.vithey.content.dto.response.AuthorSummaryResponse;
import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import com.vithey.content.mapper.PostMapper;
import com.vithey.content.repository.CommentRepository;
import com.vithey.content.repository.ReactionRepository;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class PostEnrichmentService {

  private final PostMapper postMapper;
  private final UserProfileClient userProfileClient;
  private final FileServiceClient fileServiceClient;
  private final ReactionRepository reactionRepository;
  private final CommentRepository commentRepository;

  public PostEnrichmentService(
      PostMapper postMapper,
      UserProfileClient userProfileClient,
      FileServiceClient fileServiceClient,
      ReactionRepository reactionRepository,
      CommentRepository commentRepository
  ) {
    this.postMapper = postMapper;
    this.userProfileClient = userProfileClient;
    this.fileServiceClient = fileServiceClient;
    this.reactionRepository = reactionRepository;
    this.commentRepository = commentRepository;
  }

  public PostResponse enrich(Post post, UUID viewerId) {
    PostResponse base = postMapper.toBaseResponse(post);
    AuthorSummaryResponse author = resolveAuthor(post.getAuthorId());
    String mediaUrl = resolveMediaUrl(post.getMediaFileId());
    long reactionCount = reactionRepository.countByPostId(post.getId());
    long commentCount = commentRepository.countByPostId(post.getId());
    boolean userReacted = viewerId != null && reactionRepository.existsByPostIdAndUserId(post.getId(), viewerId);

    return new PostResponse(
        base.postId(),
        author,
        base.type(),
        base.content(),
        mediaUrl,
        postMapper.toJobMeta(post),
        reactionCount,
        commentCount,
        userReacted,
        base.createdAt()
    );
  }

  public AuthorSummaryResponse resolveAuthor(UUID userId) {
    var response = userProfileClient.getProfile(userId);
    if (response.data() == null) {
      return new AuthorSummaryResponse(userId, "Unknown User", null);
    }
    return new AuthorSummaryResponse(
        response.data().userId(),
        response.data().fullName(),
        response.data().avatarUrl()
    );
  }

  private String resolveMediaUrl(UUID mediaFileId) {
    if (mediaFileId == null) {
      return null;
    }
    var response = fileServiceClient.getFile(mediaFileId);
    return response.data() == null ? null : response.data().url();
  }
}
