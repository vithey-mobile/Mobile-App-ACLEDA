package com.vithey.content.controller;

import com.vithey.content.dto.request.CreateCommentRequest;
import com.vithey.content.dto.response.CommentResponse;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.CommentService;
import com.vithey.content.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/posts/{postId}/comments")
public class CommentController {

  private final CommentService commentService;
  private final CurrentUserProvider currentUserProvider;

  public CommentController(CommentService commentService, CurrentUserProvider currentUserProvider) {
    this.commentService = commentService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<CommentResponse>>> getComments(
      @PathVariable UUID postId,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(commentService.getComments(postId, page, limit));
  }

  @PostMapping
  ResponseEntity<ApiResponseWrapper<CommentResponse>> addComment(
      @PathVariable UUID postId,
      @Valid @RequestBody CreateCommentRequest request
  ) {
    UUID authorId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(commentService.addComment(postId, authorId, request)));
  }
}
