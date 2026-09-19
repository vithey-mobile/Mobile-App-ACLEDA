package com.vithey.ai.service;

import com.vithey.ai.dto.request.CvSuggestRequest;
import com.vithey.ai.dto.response.CvSuggestResponse;
import com.vithey.ai.entity.AiCvInteraction;
import com.vithey.ai.entity.AiTopic;
import com.vithey.ai.repository.AiCvInteractionRepository;
import com.vithey.ai.security.CurrentUser;
import com.vithey.ai.util.ApiResponseWrapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CvSuggestionService {

  private final AiCvInteractionRepository interactionRepository;
  private final ChatReplyService chatReplyService;

  public CvSuggestionService(
      AiCvInteractionRepository interactionRepository,
      ChatReplyService chatReplyService
  ) {
    this.interactionRepository = interactionRepository;
    this.chatReplyService = chatReplyService;
  }

  @Transactional
  public ApiResponseWrapper<CvSuggestResponse> suggest(CurrentUser user, CvSuggestRequest request) {
    String suggestedText;
    if (chatReplyService.isStubMode()) {
      suggestedText = """
          ## Improved %s (demo stub)

          %s

          _Tip: tighten verbs, quantify outcomes, and keep this section under 4 lines._
          """.formatted(request.section(), request.originalText().strip());
    } else {
      suggestedText = chatReplyService.reply(
          "Improve this CV section (" + request.section() + "): " + request.originalText(),
          AiTopic.CV,
          null
      );
    }

    AiCvInteraction interaction = new AiCvInteraction();
    interaction.setUserId(user.userId());
    interaction.setSection(request.section());
    interaction.setOriginalText(request.originalText());
    interaction.setSuggestedText(suggestedText);
    interaction.setCvFileId(request.cvFileId());
    interactionRepository.save(interaction);

    return ApiResponseWrapper.success(new CvSuggestResponse(
        suggestedText,
        interaction.getId()
    ));
  }
}
