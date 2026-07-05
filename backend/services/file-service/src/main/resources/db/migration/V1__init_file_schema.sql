CREATE TABLE file_metadata (
    id UUID PRIMARY KEY,
    owner_user_id UUID NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(32) NOT NULL,
    mime_type VARCHAR(160) NOT NULL,
    size_bytes BIGINT NOT NULL,
    bucket VARCHAR(64) NOT NULL,
    object_key TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX uq_file_metadata_object_key ON file_metadata (object_key);
CREATE INDEX idx_file_metadata_owner_user_id ON file_metadata (owner_user_id);
CREATE INDEX idx_file_metadata_file_type ON file_metadata (file_type);
CREATE INDEX idx_file_metadata_active ON file_metadata (id) WHERE deleted_at IS NULL;
