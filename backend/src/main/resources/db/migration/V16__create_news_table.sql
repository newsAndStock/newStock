CREATE TABLE news
(
    news_id   VARCHAR(255) PRIMARY KEY,
    category  VARCHAR(255),
    title     TEXT,
    date      VARCHAR(100),
    content   TEXT,
    press     VARCHAR(255),
    image_url VARCHAR(500)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE keyword
(
    keyword_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    news_id    VARCHAR(255),
    word       VARCHAR(255),
    count      BIGINT,
    FOREIGN KEY (news_id) REFERENCES news (news_id) ON DELETE CASCADE
)CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE total_keyword
(
    total_keyword_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    word             VARCHAR(255),
    count            BIGINT,
    date             VARCHAR(255)
)CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
