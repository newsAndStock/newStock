CREATE TABLE IF NOT EXISTS member_stocks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    stock_code VARCHAR(10) NOT NULL,
    average_price FLOAT NOT NULL,
    holdings BIGINT NOT NULL,
    total_price DOUBLE NOT NULL,
    member_id BIGINT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
);

