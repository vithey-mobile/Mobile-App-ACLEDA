package com.vithey.content.controller;

import com.vithey.content.dto.response.AuthorSummaryResponse;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.FollowService;
import com.vithey.content.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/{userId}")
public class FollowController {

  private final FollowService followService;
  private final CurrentUserProvider currentUserProvider;

  public FollowController(FollowService followService, CurrentUserProvider currentUserProvider) {
    this.followService = followService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping("/follow")
  ResponseEntity<Void> follow(@PathVariable UUID userId) {
    UUID followerId = currentUserProvider.requireCurrentUser().userId();
    followService.follow(followerId, userId);
    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  @DeleteMapping("/follow")
  ResponseEntity<Void> unfollow(@PathVariable UUID userId) {
    UUID followerId = currentUserProvider.requireCurrentUser().userId();
    followService.unfollow(followerId, userId);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/followers")
  ResponseEntity<ApiResponseWrapper<List<AuthorSummaryResponse>>> getFollowers(
      @PathVariable UUID userId,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(followService.getFollowers(userId, page, limit));
  }

  @GetMapping("/following")
  ResponseEntity<ApiResponseWrapper<List<AuthorSummaryResponse>>> getFollowing(
      @PathVariable UUID userId,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(followService.getFollowing(userId, page, limit));
  }
}
