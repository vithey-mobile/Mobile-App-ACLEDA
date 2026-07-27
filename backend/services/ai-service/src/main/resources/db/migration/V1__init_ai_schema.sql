CREATE TABLE ai_chat_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    topic VARCHAR(32) NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_ai_chat_sessions_topic CHECK (topic IN ('CV_HELP','MOCK_INTERVIEW','FINANCE_QA'))
);

CREATE INDEX idx_ai_chat_sessions_user_updated ON ai_chat_sessions (user_id, updated_at DESC);

CREATE TABLE ai_chat_messages (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES ai_chat_sessions (id) ON DELETE CASCADE,
    role VARCHAR(16) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_ai_chat_messages_role CHECK (role IN ('user','assistant','system'))
);

CREATE INDEX idx_ai_chat_messages_session_created ON ai_chat_messages (session_id, created_at);

CREATE TABLE ai_cv_interactions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    section VARCHAR(64) NOT NULL,
    original_text TEXT NOT NULL,
    suggested_text TEXT NOT NULL,
    cv_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_ai_cv_interactions_section CHECK (section IN ('summary','experience','education','skills'))
);

CREATE INDEX idx_ai_cv_interactions_user_id ON ai_cv_interactions (user_id);
CREATE INDEX idx_ai_cv_interactions_cv_id ON ai_cv_interactions (cv_id);