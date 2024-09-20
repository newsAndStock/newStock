CREATE TABLE IF NOT EXISTS trading (
     id BIGINT AUTO_INCREMENT PRIMARY KEY,
     stock_code VARCHAR(255) NOT NULL,
     quantity INT NOT NULL,
     bid INT NOT NULL,
     order_type VARCHAR(255) NOT NULL,
     order_time TIMESTAMP NOT NULL,
     order_complete_time TIMESTAMP NOT NULL,
     member_id BIGINT NOT NULL,
     trade_type VARCHAR(255) NOT NULL,
     FOREIGN KEY (member_id) REFERENCES member(id)
);