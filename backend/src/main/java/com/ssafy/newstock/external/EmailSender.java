package com.ssafy.newstock.external;

import com.ssafy.newstock.external.exception.EmailSendFailException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class EmailSender {
    private final JavaMailSender javaMailSender;
    private final TemplateEngine templateEngine;

    public void sendTemporaryPassword(String email, String id, String temporaryPassword) {
        MimeMessage mimeMessage = javaMailSender.createMimeMessage();

        Context context = new Context();
        context.setVariable("email", email);
        context.setVariable("id", id);
        context.setVariable("temporaryPassword", temporaryPassword);
        String emailContent = templateEngine.process("reset-password", context);

        try {
            MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            mimeMessageHelper.setTo(email);
            mimeMessageHelper.setSubject("[NEWSTOCK] 임시 비밀번호입니다");
            mimeMessageHelper.setText(emailContent, true);
            javaMailSender.send(mimeMessage);
            log.info("이메일 전송 완료. 수신 이메일: {}, 임시비밀번호: {}, 보낸 시간: {}", email, temporaryPassword, LocalDateTime.now());
        } catch (Exception e) {
            throw new EmailSendFailException("이메일 전송 실패: " + email, e);
        }
    }
}
