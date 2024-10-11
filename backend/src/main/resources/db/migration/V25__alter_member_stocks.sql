ALTER TABLE member_stocks
    ADD CONSTRAINT chk_holdings CHECK (holdings >= 0);