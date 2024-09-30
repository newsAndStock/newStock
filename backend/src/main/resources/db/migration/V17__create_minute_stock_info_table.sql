CREATE TABLE minute_stock_info
(
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    stock_code    VARCHAR(255) NOT NULL,
    time          VARCHAR(255) NOT NULL,
    opening_price VARCHAR(255) NOT NULL,
    closing_price VARCHAR(255) NOT NULL,
    highest_price VARCHAR(255) NOT NULL,
    lowest_price  VARCHAR(255) NOT NULL,
    volume        BIGINT       NOT NULL
);
