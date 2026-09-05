package com.vithey.ai.service;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

/**
 * Tracks in-flight chat generations so the Flutter "Stop" button can cancel
 * them through {@code DELETE /api/v1/ai/chat/requests/{requestId}}.
 *
 * <p>Entries live in memory only (single instance per pod) and are purged
 * after a TTL, so a {@code DELETE} for a finished request still answers
 * {@code 204} instead of {@code 404} for a short window.
 */
@Component
public class ChatRequestRegistry {

  public enum State {
    RUNNING,
    DONE,
    CANCELLED
  }

  public record Entry(UUID requestId, UUID userId, State state, Instant createdAt) {
  }

  private static final Duration TTL = Duration.ofMinutes(15);

  private final Map<UUID, Entry> requests = new ConcurrentHashMap<>();
  private final Duration ttl;

  public ChatRequestRegistry() {
    this(TTL);
  }

  ChatRequestRegistry(Duration ttl) {
    this.ttl = ttl;
  }

  /** Registers a new RUNNING request for the given user and returns its id. */
  public UUID register(UUID userId) {
    purge();
    UUID requestId = UUID.randomUUID();
    requests.put(requestId, new Entry(requestId, userId, State.RUNNING, Instant.now()));
    return requestId;
  }

  public Optional<Entry> find(UUID requestId) {
    purge();
    return Optional.ofNullable(requests.get(requestId));
  }

  public boolean isCancelled(UUID requestId) {
    Entry entry = requests.get(requestId);
    return entry != null && entry.state() == State.CANCELLED;
  }

  /** Marks a RUNNING request as CANCELLED; leaves DONE/CANCELLED entries untouched. */
  public void cancel(UUID requestId) {
    requests.computeIfPresent(requestId, (id, entry) ->
        entry.state() == State.RUNNING
            ? new Entry(id, entry.userId(), State.CANCELLED, entry.createdAt())
            : entry
    );
  }

  /** Marks a RUNNING request as DONE; never overrides a CANCELLED state. */
  public void markDone(UUID requestId) {
    requests.computeIfPresent(requestId, (id, entry) ->
        entry.state() == State.RUNNING
            ? new Entry(id, entry.userId(), State.DONE, entry.createdAt())
            : entry
    );
  }

  private void purge() {
    Instant cutoff = Instant.now().minus(ttl);
    requests.entrySet().removeIf(entry -> entry.getValue().createdAt().isBefore(cutoff));
  }
}
