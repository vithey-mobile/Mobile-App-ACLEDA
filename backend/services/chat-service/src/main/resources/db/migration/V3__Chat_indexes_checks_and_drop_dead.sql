CREATE INDEX IF NOT EXISTS idx_conversations_updated_at
    ON conversations (updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_conversations_status
    ON conversations (status);

ALTER TABLE conversations DROP CONSTRAINT IF EXISTS chk_conversations_status;
ALTER TABLE conversations
    ADD CONSTRAINT chk_conversations_status
    CHECK (status IN ('PENDING', 'ACTIVE', 'BLOCKED', 'DECLINED', 'ARCHIVED', 'CLOSED'));

ALTER TABLE conversation_participants DROP CONSTRAINT IF EXISTS chk_conversation_participants_role;
ALTER TABLE conversation_participants
    ADD CONSTRAINT chk_conversation_participants_role
    CHECK (role IN ('REQUESTER', 'RECIPIENT', 'MEMBER', 'ADMIN'));

ALTER TABLE messages DROP CONSTRAINT IF EXISTS chk_messages_status;
ALTER TABLE messages
    ADD CONSTRAINT chk_messages_status
    CHECK (status IN ('SENT', 'DELIVERED', 'READ', 'DELETED'));

DROP INDEX IF EXISTS idx_messages_sender;
DROP INDEX IF EXISTS idx_blocks_blocker;
DROP INDEX IF EXISTS idx_user_reports_reporter;
DROP INDEX IF EXISTS idx_user_reports_reported;
