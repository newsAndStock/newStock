CREATE TABLE IF NOT EXISTS Stock (
    Stock_code VARCHAR(20) NOT NULL,
    name VARCHAR(255),
    market VARCHAR(100),
    industry VARCHAR(100),
    listing_date VARCHAR(100),
    settlement_month VARCHAR(100),
    capital VARCHAR(100),
    issued_shares VARCHAR(100),
    PRIMARY KEY (Stock_code)
);

ALTER TABLE Stock
    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;