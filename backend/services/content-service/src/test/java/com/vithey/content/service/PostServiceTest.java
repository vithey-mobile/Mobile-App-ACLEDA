package com.vithey.content.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.content.client.FileServiceClient;
import com.vithey.content.dto.request.CreatePostRequest;
import com.vithey.content.dto.response.FileMetadataResponse;
import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import com.vithey.content.entity.PostType;
import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.exception.ApiException;
import com.vithey.content.exception.ErrorCode;
import com.vithey.content.repository.PostRepository;
import com.vithey.content.util.ApiResponseWrapper;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PostServiceTest {

  @Mock
  private PostRepository postRepository;

  @Mock
  private FileServiceClient fileServiceClient;

  @Mock
  private PostEnrichmentService postEnrichmentService;

  @Mock
  private ContentEventPublisher contentEventPublisher;

  @InjectMocks
  private PostService postService;

  @Test
  void createPost_allowsTextOnlyPosterPost() {
    UUID authorId = UUID.randomUUID();
    CreatePostRequest request = new CreatePostRequest(PostType.POSTER, "hello world", null, null, null);
    when(postRepository.save(any(Post.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(postEnrichmentService.enrich(any(Post.class), any(UUID.class)))
        .thenReturn(new PostResponse(
            UUID.randomUUID(), null, PostType.POSTER, "hello world", null, null, 0, 0, false, false, null, null
        ));

    PostResponse response = postService.createPost(authorId, request);

    assertEquals(PostType.POSTER, response.type());
    assertEquals("hello world", response.content());
    verify(postRepository).save(any(Post.class));
    verify(fileServiceClient, never()).getFile(any());
  }

  @Test
  void createPost_rejectsVideoPostWithoutFileId() {
    CreatePostRequest request = new CreatePostRequest(PostType.VIDEO, "my reel", null, null, null);

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.createPost(UUID.randomUUID(), request)
    );

    assertEquals(ErrorCode.VALIDATION_ERROR, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }

  @Test
  void createPost_rejectsEmptyPostWithoutContentOrMedia() {
    CreatePostRequest request = new CreatePostRequest(PostType.POSTER, "   ", null, null, null);

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.createPost(UUID.randomUUID(), request)
    );

    assertEquals(ErrorCode.VALIDATION_ERROR, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }

  @Test
  void createPost_rejectsJobWithoutTitle() {
    CreatePostRequest request = new CreatePostRequest(
        PostType.JOB,
        "hiring",
        null,
        new CreatePostRequest.JobMetaRequest(null, "desc", "req", null),
        null
    );

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.createPost(UUID.randomUUID(), request)
    );

    assertEquals(ErrorCode.VALIDATION_ERROR, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }

  @Test
  void createPost_persistsJobAndPublishesEvent() {
    UUID authorId = UUID.randomUUID();
    CreatePostRequest request = new CreatePostRequest(
        PostType.JOB,
        "hiring",
        null,
        new CreatePostRequest.JobMetaRequest("Intern", "desc", "req", null),
        null
    );
    when(postRepository.save(any(Post.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(postEnrichmentService.enrich(any(Post.class), any(UUID.class)))
        .thenReturn(new PostResponse(
            UUID.randomUUID(), null, PostType.JOB, "hiring", null, null, 0, 0, false, false, null, null
        ));

    PostResponse response = postService.createPost(authorId, request);

    assertEquals(PostType.JOB, response.type());
    verify(contentEventPublisher).publishPostCreated(any());
    verify(fileServiceClient, never()).getFile(any());
  }

  @Test
  void createPost_scheduledPostDoesNotPublishEventImmediately() {
    UUID authorId = UUID.randomUUID();
    java.time.OffsetDateTime future = java.time.OffsetDateTime.now(java.time.ZoneOffset.UTC).plusDays(1);
    CreatePostRequest request = new CreatePostRequest(PostType.POSTER, "future post", null, null, future);
    when(postRepository.save(any(Post.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(postEnrichmentService.enrich(any(Post.class), any(UUID.class)))
        .thenReturn(new PostResponse(
            UUID.randomUUID(), null, PostType.POSTER, "future post", null, null, 0, 0, false, false, future, future
        ));

    PostResponse response = postService.createPost(authorId, request);

    assertEquals(PostType.POSTER, response.type());
    verify(postRepository).save(any(Post.class));
    verify(contentEventPublisher, never()).publishPostCreated(any());
  }

  @Test
  void createPost_rejectsMismatchedMediaType() {
    UUID fileId = UUID.randomUUID();
    CreatePostRequest request = new CreatePostRequest(PostType.VIDEO, "clip", fileId, null, null);
    when(fileServiceClient.getFile(fileId)).thenReturn(ApiResponseWrapper.success(
        new FileMetadataResponse(fileId, "POSTER", "http://x")
    ));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.createPost(UUID.randomUUID(), request)
    );

    assertEquals(ErrorCode.INVALID_FILE, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }
}
