CREATE TABLE IF NOT EXISTS stock_info (
                            id BIGINT AUTO_INCREMENT PRIMARY KEY,
                            date VARCHAR(255) NOT NULL,
                            highest_price VARCHAR(255) NOT NULL,
                            lowest_price VARCHAR(255) NOT NULL,
                            opening_price VARCHAR(255) NOT NULL,
                            closing_price VARCHAR(255) NOT NULL,
                            volume BIGINT NOT NULL,
                            stock_code VARCHAR(255) NOT NULL,
                            period VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
