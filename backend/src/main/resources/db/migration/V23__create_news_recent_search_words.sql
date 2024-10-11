CREATE TABLE news_recent_search_words (
                                          id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                          keyword VARCHAR(255) NOT NULL,
                                          date DATETIME NOT NULL,
                                          member_id BIGINT NOT NULL,
                                          FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
);
