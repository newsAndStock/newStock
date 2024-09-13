package com.ssafy.newstock.common.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    EXPIRED_ACCESS_TOKEN("4000", "AccessToken 만료", HttpStatus.UNAUTHORIZED),
    EXPIRED_REFRESH_TOKEN("4001", "RefreshToken 만료", HttpStatus.UNAUTHORIZED),
    INVALID_TOKEN("4002", "유효하지 않은 토큰", HttpStatus.UNAUTHORIZED),
    ACCESS_DENIED("4003", "접근 권한이 없음", HttpStatus.FORBIDDEN),
    ENTITY_NOT_FOUND("4004", "엔티티 없음", HttpStatus.BAD_REQUEST),
    ILLEGAL_ARGUMENT("4005", "적절하지 않은 인자", HttpStatus.BAD_REQUEST),
    MISSING_TOKEN("4006", "토큰 없음", HttpStatus.UNAUTHORIZED),
    INVALID_REQUEST_PARAMS("4007", "잘못된 요청 파라미터", HttpStatus.BAD_REQUEST),
    INTERNAL_SERVER_ERROR("5000", "서버 에러", HttpStatus.INTERNAL_SERVER_ERROR),
    EMAIL_SEND_FAIL("5001", "이메일 전송 실패", HttpStatus.INTERNAL_SERVER_ERROR);

    private final String code;
    private final String message;
    private final HttpStatus status;
}
