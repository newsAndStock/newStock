ALTER TABLE member
    ADD CONSTRAINT unique_email UNIQUE (email),
    ADD CONSTRAINT unique_nickname UNIQUE (nickname);

ALTER TABLE member
    ADD deposit BIGINT NOT NULL;