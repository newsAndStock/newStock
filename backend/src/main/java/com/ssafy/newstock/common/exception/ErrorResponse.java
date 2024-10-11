package com.ssafy.newstock.common.exception;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ErrorResponse {
    private String code;
    private String message;

    public ErrorResponse(ErrorCode errorCode) {
        this(errorCode.getCode(), errorCode.getMessage());
    }

    public ErrorResponse(ErrorCode errorCode, String message) {
        this(errorCode.getCode(), message);
    }

    public ErrorResponse(String code, String message) {
        this.code = code;
        this.message = message;
    }
}

