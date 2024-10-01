ALTER TABLE member_stocks
    MODIFY COLUMN average_price BIGINT NOT NULL,
    MODIFY COLUMN total_price BIGINT NOT NULL;