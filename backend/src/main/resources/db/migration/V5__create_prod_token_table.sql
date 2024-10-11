CREATE TABLE IF NOT EXISTS prod_token (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        value VARCHAR(500) NOT NULL ,
        created_at DATE NOT NULL
);
