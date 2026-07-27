CREATE INDEX idx_conversations_updated_at
    ON conversations (updated_at DESC);

CREATE INDEX idx_conversations_status
    ON conversations (status);

ALTER TABLE conversations
    ADD CONSTRAINT chk_conversations_status
    CHECK (status IN ('PENDING', 'ACTIVE', 'BLOCKED', 'DECLINED'));

ALTER TABLE conversation_participants
    ADD CONSTRAINT chk_conversation_participants_role
    CHECK (role IN ('REQUESTER', 'RECIPIENT'));

ALTER TABLE messages
    ADD CONSTRAINT chk_messages_status
    CHECK (status IN ('SENT', 'DELIVERED', 'READ'));

DROP INDEX IF EXISTS idx_messages_sender;
DROP INDEX IF EXISTS idx_blocks_blocker;
DROP INDEX IF EXISTS idx_user_reports_reporter;
DROP INDEX IF EXISTS idx_user_reports_reported;
