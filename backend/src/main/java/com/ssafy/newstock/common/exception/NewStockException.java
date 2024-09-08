package com.ssafy.newstock.common.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class NewStockException extends RuntimeException {
    private final String code;
    private final String message;
    private final HttpStatus status;

    public NewStockException(ErrorCode errorCode) {
        this(errorCode, errorCode.getMessage());
    }

    public NewStockException(ErrorCode errorCode, String message) {
        this(null, errorCode, message);
    }

    public NewStockException(Throwable cause, ErrorCode errorCode) {
        this(cause, errorCode.getCode(), errorCode.getMessage(), errorCode.getStatus());
    }

    public NewStockException(Throwable cause, ErrorCode errorCode, String message) {
        this(cause, errorCode.getCode(), message, errorCode.getStatus());
    }

    public NewStockException(Throwable cause, String code, String message, HttpStatus status) {
        super(message, cause);
        this.code = code;
        this.message = message;
        this.status = status;
    }
}
