CREATE TABLE ai_chat_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    topic VARCHAR(32) NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_chat_sessions_user_id ON ai_chat_sessions (user_id);
CREATE INDEX idx_ai_chat_sessions_updated_at ON ai_chat_sessions (updated_at DESC);

CREATE TABLE ai_chat_messages (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES ai_chat_sessions (id) ON DELETE CASCADE,
    role VARCHAR(16) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_chat_messages_session_id ON ai_chat_messages (session_id);
CREATE INDEX idx_ai_chat_messages_created_at ON ai_chat_messages (created_at);

CREATE TABLE ai_cv_interactions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    section VARCHAR(64) NOT NULL,
    original_text TEXT NOT NULL,
    suggested_text TEXT NOT NULL,
    cv_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_cv_interactions_user_id ON ai_cv_interactions (user_id);
