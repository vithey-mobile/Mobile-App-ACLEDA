-- Idempotent: V1 already defines UNIQUE(cv_file_id) and fk_job_applications_cv_file.
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_cvs_cv_file_id
    ON user_cvs (cv_file_id);

ALTER TABLE job_applications DROP CONSTRAINT IF EXISTS fk_job_applications_cv_file;
ALTER TABLE job_applications
    ADD CONSTRAINT fk_job_applications_cv_file
    FOREIGN KEY (cv_file_id) REFERENCES user_cvs (cv_file_id);
