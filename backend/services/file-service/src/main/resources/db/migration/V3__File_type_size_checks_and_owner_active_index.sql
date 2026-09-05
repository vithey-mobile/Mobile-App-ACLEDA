ALTER TABLE file_metadata
    ADD CONSTRAINT chk_file_metadata_file_type
    CHECK (file_type IN ('AVATAR', 'CV', 'POSTER', 'VIDEO'));

ALTER TABLE file_metadata
    ADD CONSTRAINT chk_file_metadata_size_bytes_positive
    CHECK (size_bytes > 0);

CREATE INDEX idx_file_metadata_owner_active
    ON file_metadata (owner_user_id)
    WHERE deleted_at IS NULL;
