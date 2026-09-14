CREATE INDEX idx_payments_fee_id
    ON payments (fee_id);

ALTER TABLE fees
    ADD CONSTRAINT chk_fees_amount_positive
    CHECK (amount > 0);

ALTER TABLE payments
    ADD CONSTRAINT chk_payments_amount_positive
    CHECK (amount > 0);
