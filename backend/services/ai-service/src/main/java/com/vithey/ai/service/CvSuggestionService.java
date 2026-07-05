package com.vithey.ai.service;

import com.vithey.ai.client.GeneralRetrievalClient;
import com.vithey.ai.dto.request.CvSuggestRequest;
import com.vithey.ai.dto.response.CvSuggestResponse;
import com.vithey.ai.entity.AiCvInteraction;
import com.vithey.ai.entity.AiTopic;
import com.vithey.ai.repository.AiCvInteractionRepository;
import com.vithey.ai.security.CurrentUser;
import com.vithey.ai.support.QueryEnricher;
import com.vithey.ai.util.ApiResponseWrapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CvSuggestionService {

  private final AiCvInteractionRepository interactionRepository;
  private final GeneralRetrievalClient generalRetrievalClient;

  public CvSuggestionService(
      AiCvInteractionRepository interactionRepository,
      GeneralRetrievalClient generalRetrievalClient
  ) {
    this.interactionRepository = interactionRepository;
    this.generalRetrievalClient = generalRetrievalClient;
  }

  @Transactional
  public ApiResponseWrapper<CvSuggestResponse> suggest(CurrentUser user, CvSuggestRequest request) {
    String query = QueryEnricher.enrich(
        "Improve this CV section (" + request.section() + "): " + request.originalText(),
        AiTopic.CV
    );
    String suggestedText = generalRetrievalClient.retrieve(query, null);

    AiCvInteraction interaction = new AiCvInteraction();
    interaction.setUserId(user.userId());
    interaction.setSection(request.section());
    interaction.setOriginalText(request.originalText());
    interaction.setSuggestedText(suggestedText);
    interaction.setCvId(request.cvId());
    interactionRepository.save(interaction);

    return ApiResponseWrapper.success(new CvSuggestResponse(
        suggestedText,
        interaction.getId()
    ));
  }
}
