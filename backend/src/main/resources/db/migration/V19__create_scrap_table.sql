CREATE TABLE scrap (
    scrap_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    scrap_content TEXT,
    news_id VARCHAR(255) NOT NULL,
    scrap_date DATETIME NOT NULL,
    member_id BIGINT NOT NULL,
    CONSTRAINT fk_scrap_news FOREIGN KEY (news_id) REFERENCES news(news_id) ON DELETE CASCADE,
    CONSTRAINT fk_scrap_member FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;