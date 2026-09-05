CREATE TABLE job_applications (
    id UUID PRIMARY KEY,
    job_post_id UUID NOT NULL,
    applicant_id UUID NOT NULL,
    cv_file_id UUID NOT NULL,
    cover_note TEXT,
    status VARCHAR(32) NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_job_applications_post_applicant UNIQUE (job_post_id, applicant_id)
);

CREATE INDEX idx_job_applications_applicant ON job_applications (applicant_id);
CREATE INDEX idx_job_applications_job_post ON job_applications (job_post_id);
CREATE INDEX idx_job_applications_status ON job_applications (status);

CREATE TABLE user_cvs (
    user_id UUID PRIMARY KEY,
    cv_file_id UUID NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
