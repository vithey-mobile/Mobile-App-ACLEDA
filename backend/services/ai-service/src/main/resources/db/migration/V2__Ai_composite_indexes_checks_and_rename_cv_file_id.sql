-- Composite indexes for common query patterns
CREATE INDEX idx_ai_chat_sessions_user_updated
    ON ai_chat_sessions (user_id, updated_at DESC);

CREATE INDEX idx_ai_chat_messages_session_created
    ON ai_chat_messages (session_id, created_at);

-- Drop single-column indexes superseded by composites (leftmost prefix covered)
DROP INDEX IF EXISTS idx_ai_chat_sessions_user_id;
DROP INDEX IF EXISTS idx_ai_chat_messages_session_id;

-- Enum CHECK constraints aligned with AiTopic / AiMessageRole
ALTER TABLE ai_chat_sessions
    ADD CONSTRAINT chk_ai_chat_sessions_topic
    CHECK (topic IN ('CV', 'JOB', 'INTERVIEW', 'STUDENT', 'FINANCE'));

ALTER TABLE ai_chat_messages
    ADD CONSTRAINT chk_ai_chat_messages_role
    CHECK (role IN ('USER', 'ASSISTANT'));

-- Align CV reference naming with career_db.user_cvs.cv_file_id (no cross-DB FK)
ALTER TABLE ai_cv_interactions RENAME COLUMN cv_id TO cv_file_id;

CREATE INDEX idx_ai_cv_interactions_cv_file_id
    ON ai_cv_interactions (cv_file_id);
