package com.ssafy.newstock.member.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.member.controller.request.SignUpRequest;
import com.ssafy.newstock.member.service.MemberService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class MemberController {
    private final MemberService memberService;

    @PostMapping("/sign-up")
    public ResponseEntity<Void> signUp(@Valid @RequestBody SignUpRequest request) {
        memberService.signUp(request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/check-email")
    public boolean checkEmail(@RequestParam String email) {
        return memberService.isEmailDuplicated(email);
    }

    @GetMapping("/check-nickname")
    public boolean checkNickname(@RequestParam String nickname) {
        return memberService.isNicknameDuplicated(nickname);
    }

    @PostMapping("/send-email")
    public void sendPasswordEmail(@RequestParam("email") String email) {
        memberService.sendPasswordEmail(email);
    }

    @GetMapping("/reset-password")
    public void resetPassword(@RequestParam("email") String email, @RequestParam("id") String id,
                              HttpServletResponse response) throws IOException {
        memberService.resetPassword(email, id);
        response.sendRedirect("/reset-password-success");
    }

    @PostMapping("/attendance")
    public ResponseEntity<Void> checkAttendance(@LoginMember Long memberId, @RequestParam Long point) {
        memberService.checkAttendance(memberId, point);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/attendance")
    public List<String> getAttendance(@LoginMember Long memberId, @RequestParam int month) {
        return memberService.getAttendance(memberId, month);
    }
}
