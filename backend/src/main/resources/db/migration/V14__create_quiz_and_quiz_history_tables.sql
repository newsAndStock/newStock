CREATE TABLE quiz
(
    id       INT AUTO_INCREMENT PRIMARY KEY,
    question VARCHAR(255) NOT NULL,
    answer   VARCHAR(255) NOT NULL
);

CREATE TABLE quiz_history
(
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id  BIGINT NOT NULL,
    quiz_index INT    NOT NULL,
    CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES member (id) ON DELETE CASCADE
);
