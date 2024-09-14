package com.ssafy.newstock.infra;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.TreeMap;

@RestController
public class HealthCheckController {


    @Value("${spring.profiles.active}")
    private String env;

    @Value("${server.port}")
    private String serverPort;
    @Value("${server.address}")
    private String serverAddress;

    @Value("${serverName}")
    private String serverName;

    @GetMapping("/hc")
    public ResponseEntity<?> healthCheck() {

        Map<String, String> responseDate = new TreeMap<>();
        responseDate.put("serverName", serverName);
        responseDate.put("serverAddress", serverAddress);
        responseDate.put("serverPort", serverPort);
        responseDate.put("env", env);

        return ResponseEntity.ok(responseDate);
    }

    @GetMapping("/env")
    public ResponseEntity<?> getEnv() {

        return ResponseEntity.ok(env);
    }
}
