package com.ssafy.newstock.auth.exception;

import com.ssafy.newstock.common.exception.NewStockException;

import static com.ssafy.newstock.common.exception.ErrorCode.EXPIRED_REFRESH_TOKEN;

public class ExpiredRefreshTokenException extends NewStockException {
    public ExpiredRefreshTokenException() {
        super(EXPIRED_REFRESH_TOKEN);
    }
}
