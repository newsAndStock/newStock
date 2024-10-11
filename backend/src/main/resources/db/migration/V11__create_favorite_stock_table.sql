CREATE TABLE IF NOT EXISTS favorite_stock (
                                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                              member_id BIGINT NOT NULL,
                                              stock_code VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                                              FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE ON UPDATE CASCADE,
                                              FOREIGN KEY (stock_code) REFERENCES stock(stock_code) ON DELETE CASCADE ON UPDATE CASCADE,
                                              UNIQUE KEY unique_favorite (member_id, stock_code)
);
