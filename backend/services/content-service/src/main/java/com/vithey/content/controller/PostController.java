package com.vithey.content.controller;

import com.vithey.content.dto.request.CreatePostRequest;
import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.PostType;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.FeedService;
import com.vithey.content.service.PostService;
import com.vithey.content.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class PostController {

  private final FeedService feedService;
  private final PostService postService;
  private final CurrentUserProvider currentUserProvider;

  public PostController(
      FeedService feedService,
      PostService postService,
      CurrentUserProvider currentUserProvider
  ) {
    this.feedService = feedService;
    this.postService = postService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping("/posts")
  ResponseEntity<ApiResponseWrapper<List<PostResponse>>> getFeed(
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID viewerId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(feedService.getFeed(viewerId, page, limit));
  }

  @PostMapping("/posts")
  ResponseEntity<ApiResponseWrapper<PostResponse>> createPost(
      @Valid @RequestBody CreatePostRequest request
  ) {
    UUID authorId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(postService.createPost(authorId, request)));
  }

  @GetMapping("/posts/{postId}")
  ResponseEntity<ApiResponseWrapper<PostResponse>> getPost(@PathVariable UUID postId) {
    UUID viewerId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(postService.getPost(postId, viewerId)));
  }

  @DeleteMapping("/posts/{postId}")
  ResponseEntity<Void> deletePost(@PathVariable UUID postId) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    postService.deletePost(postId, userId);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/users/{userId}/posts")
  ResponseEntity<ApiResponseWrapper<List<PostResponse>>> getUserPosts(
      @PathVariable UUID userId,
      @RequestParam(required = false) PostType type,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID viewerId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(postService.getUserPosts(userId, type, viewerId, page, limit));
  }
}
