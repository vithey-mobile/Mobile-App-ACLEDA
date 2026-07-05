package com.vithey.notification.service;

import com.vithey.notification.client.ContentServiceClient;
import com.vithey.notification.entity.NotificationType;
import com.vithey.notification.event.payload.ChatMessageSentEvent;
import com.vithey.notification.event.payload.ChatRequestReceivedEvent;
import com.vithey.notification.event.payload.CommentAddedEvent;
import com.vithey.notification.event.payload.FollowCreatedEvent;
import com.vithey.notification.event.payload.JobApplicationStatusChangedEvent;
import com.vithey.notification.event.payload.JobApplicationSubmittedEvent;
import com.vithey.notification.event.payload.MentionCreatedEvent;
import com.vithey.notification.event.payload.PaymentDueEvent;
import com.vithey.notification.event.payload.PaymentOverdueEvent;
import com.vithey.notification.event.payload.ReactionAddedEvent;
import feign.FeignException;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class EventNotificationService {

  private final NotificationService notificationService;
  private final ContentServiceClient contentServiceClient;

  public EventNotificationService(
      NotificationService notificationService,
      ContentServiceClient contentServiceClient
  ) {
    this.notificationService = notificationService;
    this.contentServiceClient = contentServiceClient;
  }

  public void onCommentAdded(CommentAddedEvent event) {
    UUID postAuthorId = resolvePostAuthor(event.postId());
    if (postAuthorId == null || postAuthorId.equals(event.authorId())) {
      return;
    }
    notificationService.createAndPush(
        postAuthorId,
        NotificationType.COMMENT,
        "New comment",
        "Someone commented on your post",
        event.postId(),
        "POST"
    );
  }

  public void onReactionAdded(ReactionAddedEvent event) {
    UUID postAuthorId = resolvePostAuthor(event.postId());
    if (postAuthorId == null || postAuthorId.equals(event.userId())) {
      return;
    }
    notificationService.createAndPush(
        postAuthorId,
        NotificationType.LIKE,
        "New like",
        "Someone liked your post",
        event.postId(),
        "POST"
    );
  }

  public void onFollowCreated(FollowCreatedEvent event) {
    notificationService.createAndPush(
        event.followingId(),
        NotificationType.FOLLOW,
        "New follower",
        "You have a new follower",
        event.followerId(),
        "USER"
    );
  }

  public void onMentionCreated(MentionCreatedEvent event) {
    notificationService.createAndPush(
        event.mentionedUserId(),
        NotificationType.MENTION,
        "You were mentioned",
        "Someone mentioned you in a comment",
        event.postId(),
        "POST"
    );
  }

  public void onChatRequestReceived(ChatRequestReceivedEvent event) {
    notificationService.createAndPush(
        event.recipientId(),
        NotificationType.CHAT_REQUEST,
        "New message request",
        event.initialMessage(),
        event.conversationId(),
        "CONVERSATION"
    );
  }

  public void onChatMessageSent(ChatMessageSentEvent event) {
    notificationService.createAndPush(
        event.recipientId(),
        NotificationType.CHAT,
        "New message",
        event.text(),
        event.conversationId(),
        "CONVERSATION"
    );
  }

  public void onPaymentDue(PaymentDueEvent event) {
    notificationService.createAndPush(
        event.userId(),
        NotificationType.PAYMENT,
        "Payment due soon",
        "You have a payment due on " + event.dueDate(),
        event.paymentId(),
        "PAYMENT"
    );
  }

  public void onPaymentOverdue(PaymentOverdueEvent event) {
    notificationService.createAndPush(
        event.userId(),
        NotificationType.PAYMENT,
        "Payment overdue",
        "You have an overdue payment from " + event.dueDate(),
        event.paymentId(),
        "PAYMENT"
    );
  }

  public void onJobApplicationSubmitted(JobApplicationSubmittedEvent event) {
    UUID posterId = resolvePostAuthor(event.jobPostId());
    if (posterId == null || posterId.equals(event.applicantId())) {
      return;
    }
    notificationService.createAndPush(
        posterId,
        NotificationType.JOB,
        "New job application",
        "Someone applied to your job post",
        event.applicationId(),
        "JOB_APPLICATION"
    );
  }

  public void onJobApplicationStatusChanged(JobApplicationStatusChangedEvent event) {
    notificationService.createAndPush(
        event.applicantId(),
        NotificationType.JOB,
        "Application status updated",
        "Your application status is now " + event.newStatus(),
        event.applicationId(),
        "JOB_APPLICATION"
    );
  }

  private UUID resolvePostAuthor(UUID postId) {
    try {
      var response = contentServiceClient.getPost(postId);
      if (response == null || response.data() == null || response.data().author() == null) {
        return null;
      }
      return response.data().author().userId();
    } catch (FeignException exception) {
      return null;
    }
  }
}
