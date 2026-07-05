package com.vithey.content.controller;

import com.vithey.content.dto.response.ReactionSummaryResponse;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.ReactionService;
import com.vithey.content.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/posts/{postId}/reactions")
public class ReactionController {

  private final ReactionService reactionService;
  private final CurrentUserProvider currentUserProvider;

  public ReactionController(ReactionService reactionService, CurrentUserProvider currentUserProvider) {
    this.reactionService = reactionService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping
  ResponseEntity<ApiResponseWrapper<ReactionSummaryResponse>> toggleReaction(@PathVariable UUID postId) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(reactionService.toggleReaction(postId, userId)));
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<ReactionSummaryResponse>> getReactions(@PathVariable UUID postId) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(reactionService.getReactions(postId, userId)));
  }
}
