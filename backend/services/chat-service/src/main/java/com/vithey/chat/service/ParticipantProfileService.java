package com.vithey.chat.service;

import com.vithey.chat.client.UserProfileClient;
import com.vithey.chat.dto.response.ParticipantSummaryResponse;
import org.springframework.stereotype.Service;

@Service
public class ParticipantProfileService {

  private final UserProfileClient userProfileClient;

  public ParticipantProfileService(UserProfileClient userProfileClient) {
    this.userProfileClient = userProfileClient;
  }

  public ParticipantSummaryResponse resolve(java.util.UUID userId) {
    try {
      var response = userProfileClient.getProfile(userId);
      if (response != null && response.data() != null) {
        return new ParticipantSummaryResponse(
            response.data().userId(),
            response.data().fullName(),
            response.data().avatarUrl()
        );
      }
    } catch (Exception ignored) {
    }
    return new ParticipantSummaryResponse(userId, "User", null);
  }
}
