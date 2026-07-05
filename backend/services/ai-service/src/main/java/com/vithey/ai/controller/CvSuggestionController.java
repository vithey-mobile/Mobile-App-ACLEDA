package com.vithey.ai.controller;

import com.vithey.ai.dto.request.CvSuggestRequest;
import com.vithey.ai.dto.response.CvSuggestResponse;
import com.vithey.ai.security.CurrentUserProvider;
import com.vithey.ai.service.CvSuggestionService;
import com.vithey.ai.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ai")
@Tag(name = "AI CV")
public class CvSuggestionController {

  private final CvSuggestionService cvSuggestionService;
  private final CurrentUserProvider currentUserProvider;

  public CvSuggestionController(
      CvSuggestionService cvSuggestionService,
      CurrentUserProvider currentUserProvider
  ) {
    this.cvSuggestionService = cvSuggestionService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping("/cv/suggest")
  @Operation(summary = "Suggest improved CV text")
  public ApiResponseWrapper<CvSuggestResponse> suggest(@Valid @RequestBody CvSuggestRequest request) {
    return cvSuggestionService.suggest(currentUserProvider.requireCurrentUser(), request);
  }
}
