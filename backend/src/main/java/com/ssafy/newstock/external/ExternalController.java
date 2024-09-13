package com.ssafy.newstock.external;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ExternalController {

    @GetMapping("/reset-password-success")
    public String passwordResetSuccess() {
        return "reset-password-success";
    }
}
