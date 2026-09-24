ALTER TABLE posts ADD COLUMN scheduled_at TIMESTAMPTZ;

CREATE INDEX idx_posts_scheduled_at
    ON posts (scheduled_at)
    WHERE deleted_at IS NULL;
