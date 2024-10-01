package com.ssafy.newstock.notification.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.notification.controller.response.NotificationResponse;
import com.ssafy.newstock.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @Tag(name = "SSE")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "2000", description = "SSE 연결 성공"),
            @ApiResponse(responseCode = "5000", description = "SSE 연결 실패")
    })
    @Operation(summary = "SSE 연결")
    @GetMapping(value="/subscribe", produces = "text/event-stream")
    public SseEmitter subscribe(@LoginMember Long memberId, @RequestHeader(value="Last-Event-ID", required = false, defaultValue = "") String lastEventId ){

        return notificationService.subscribe(memberId, lastEventId);
    }

    @GetMapping("/notifications")
    public ResponseEntity<List<NotificationResponse>> allNotifications(@LoginMember Long memberId){

        return ResponseEntity.status(HttpStatus.OK).body(notificationService.getAllNotification(memberId));
    }
}
