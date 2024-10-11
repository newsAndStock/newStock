package com.ssafy.newstock.keyword.controller;

import com.ssafy.newstock.keyword.service.KeyWordService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
public class KeyWordController {

    private final KeyWordService keyWordService;

    public KeyWordController(KeyWordService keyWordService) {
        this.keyWordService = keyWordService;
    }

    @GetMapping("/popular-word")
    public ResponseEntity<List<String>> popularWord(@RequestParam String date){

        return ResponseEntity.status(HttpStatus.OK).body(keyWordService.getPopularKeywords(date));
    }
}
