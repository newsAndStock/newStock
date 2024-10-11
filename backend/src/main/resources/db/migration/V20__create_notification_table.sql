CREATE TABLE notification (
                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                              receiver_id BIGINT NOT NULL,
                              stock_name VARCHAR(255) NOT NULL,
                              quantity BIGINT NOT NULL,
                              created_at TIMESTAMP NOT NULL,
                              is_read BOOLEAN NOT NULL DEFAULT FALSE
);