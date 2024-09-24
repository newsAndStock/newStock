CREATE TABLE stock_recent_search_word (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL,
    member_id BIGINT NOT NULL,
    CONSTRAINT FK_member_stock_recent_search_word FOREIGN KEY (member_id) REFERENCES member(id)
);
