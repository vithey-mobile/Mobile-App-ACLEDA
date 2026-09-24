ALTER TABLE comments
    ADD COLUMN parent_comment_id UUID REFERENCES comments (id) ON DELETE CASCADE;

CREATE INDEX idx_comments_parent ON comments (parent_comment_id) WHERE parent_comment_id IS NOT NULL;
