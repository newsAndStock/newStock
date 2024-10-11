CREATE TABLE attendance
(
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    date      DATE   NOT NULL,
    CONSTRAINT FK_attendance_member FOREIGN KEY (member_id) REFERENCES member (id) ON DELETE CASCADE
);
