CREATE INDEX idx_messages_sender ON messages (sender_id);
CREATE INDEX idx_user_reports_reporter ON user_reports (reporter_id);
CREATE INDEX idx_user_reports_reported ON user_reports (reported_id);
