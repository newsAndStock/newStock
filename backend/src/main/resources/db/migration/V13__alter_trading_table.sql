-- 1. order_complete_time 컬럼의 NOT NULL 제약 제거 (NULL 허용)
ALTER TABLE trading
    MODIFY COLUMN order_complete_time TIMESTAMP NULL;

-- 2. 거래 완료 여부를 위한 is_completed 컬럼 추가 (기본값은 false)
ALTER TABLE trading
    ADD COLUMN is_completed BOOLEAN DEFAULT false;