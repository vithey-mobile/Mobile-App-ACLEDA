ALTER TABLE notifications
    ADD CONSTRAINT chk_notifications_type
    CHECK (type IN ('LIKE', 'COMMENT', 'MENTION', 'FOLLOW', 'CHAT', 'CHAT_REQUEST', 'PAYMENT', 'JOB'));

ALTER TABLE device_tokens
    ADD CONSTRAINT chk_device_tokens_platform
    CHECK (platform IN ('ANDROID', 'IOS'));
