ALTER TABLE IF NOT EXISTS stock_info
ADD CONSTRAINT unique_stock_date_period UNIQUE (stock_code, date, period);
