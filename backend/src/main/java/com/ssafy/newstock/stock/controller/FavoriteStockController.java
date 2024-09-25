package com.ssafy.newstock.stock.controller;

import com.ssafy.newstock.auth.supports.LoginMember;
import com.ssafy.newstock.stock.service.FavoriteStockService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class FavoriteStockController {
    private final FavoriteStockService favoriteStockService;

    @PostMapping("/favorite-stock")
    public ResponseEntity<?> addFavorite(@LoginMember Long memberId, @RequestParam String stockCode){
        favoriteStockService.addFavoriteStock(memberId, stockCode);
        return ResponseEntity.ok().build();
    }
    @GetMapping("/favorite-stock")
    public ResponseEntity<?> getFavoriteStock(@LoginMember Long memberId){
        return ResponseEntity.ok(favoriteStockService.getFavoriteStockList(memberId));
    }
    @DeleteMapping("/favorite-stock")
    public ResponseEntity<?> deleteFavoriteStock(@LoginMember Long memberId, @RequestParam String stockCode){
        favoriteStockService.removeFavoriteStock(memberId, stockCode);
        return ResponseEntity.ok().build();
    }
    @GetMapping("/check/favorite-stock")
    public boolean checkFavoriteStock(@LoginMember Long memberId, @RequestParam String stockCode){
        return favoriteStockService.checkFavoriteStock(memberId, stockCode);
    }
}
