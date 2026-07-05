CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    type VARCHAR(32) NOT NULL,
    title VARCHAR(180) NOT NULL,
    body TEXT NOT NULL,
    reference_id UUID,
    reference_type VARCHAR(64),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_notifications_user_created ON notifications (user_id, created_at DESC);
CREATE INDEX idx_notifications_user_read ON notifications (user_id, is_read);

CREATE TABLE device_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    fcm_token TEXT NOT NULL,
    platform VARCHAR(16) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_device_tokens_fcm_token UNIQUE (fcm_token)
);

CREATE INDEX idx_device_tokens_user ON device_tokens (user_id);
