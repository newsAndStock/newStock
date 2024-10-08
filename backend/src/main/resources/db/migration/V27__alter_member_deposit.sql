ALTER TABLE member
    ADD CONSTRAINT check_deposit_non_negative CHECK (deposit >= 0);