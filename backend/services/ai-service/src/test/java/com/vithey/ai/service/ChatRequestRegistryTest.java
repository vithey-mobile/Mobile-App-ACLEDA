package com.vithey.ai.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class ChatRequestRegistryTest {

  private final ChatRequestRegistry registry = new ChatRequestRegistry();

  @Test
  void cancelMarksRunningRequestCancelled() {
    UUID userId = UUID.randomUUID();
    UUID requestId = registry.register(userId);

    assertThat(registry.isCancelled(requestId)).isFalse();

    registry.cancel(requestId);

    assertThat(registry.isCancelled(requestId)).isTrue();
    assertThat(registry.find(requestId))
        .hasValueSatisfying(entry -> {
          assertThat(entry.userId()).isEqualTo(userId);
          assertThat(entry.state()).isEqualTo(ChatRequestRegistry.State.CANCELLED);
        });
  }

  @Test
  void markDoneDoesNotOverrideCancelledState() {
    UUID requestId = registry.register(UUID.randomUUID());
    registry.cancel(requestId);

    registry.markDone(requestId);

    assertThat(registry.find(requestId))
        .hasValueSatisfying(entry ->
            assertThat(entry.state()).isEqualTo(ChatRequestRegistry.State.CANCELLED));
  }

  @Test
  void doneRequestIsNoLongerRunning() {
    UUID requestId = registry.register(UUID.randomUUID());
    registry.markDone(requestId);

    assertThat(registry.isCancelled(requestId)).isFalse();
    assertThat(registry.find(requestId))
        .hasValueSatisfying(entry ->
            assertThat(entry.state()).isEqualTo(ChatRequestRegistry.State.DONE));
  }

  @Test
  void unknownRequestIsNotFound() {
    assertThat(registry.find(UUID.randomUUID())).isEmpty();
  }

  @Test
  void expiredEntriesArePurged() throws InterruptedException {
    ChatRequestRegistry shortTtlRegistry = new ChatRequestRegistry(Duration.ofMillis(50));
    UUID requestId = shortTtlRegistry.register(UUID.randomUUID());

    Thread.sleep(60);

    assertThat(shortTtlRegistry.find(requestId)).isEmpty();
  }
}
