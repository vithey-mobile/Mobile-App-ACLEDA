ALTER TABLE profiles
    ADD CONSTRAINT chk_profiles_graduation_year
    CHECK (graduation_year IS NULL OR (graduation_year BETWEEN 1900 AND 2100));

ALTER TABLE user_settings
    ADD CONSTRAINT chk_user_settings_language
    CHECK (language IN ('km', 'en'));

ALTER TABLE user_settings
    ADD CONSTRAINT chk_user_settings_theme
    CHECK (theme IN ('light', 'dark', 'system'));
