package com.ssafy.newstock.external.exception;

import com.ssafy.newstock.common.exception.ErrorCode;
import com.ssafy.newstock.common.exception.NewStockException;

public class EmailSendFailException extends NewStockException {
    public EmailSendFailException(String message, Throwable cause) {
        super(cause, ErrorCode.EMAIL_SEND_FAIL, message);
    }
}
